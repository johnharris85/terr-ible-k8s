#!/bin/bash

set -xe

for i in ${control_plane1_ip} ${control_plane2_ip} ${control_plane3_ip}; do
ssh-keyscan -H \$${i} >> ~/.ssh/known_hosts
scp ./etcd-ca.crt ubuntu@\$${i}:
scp ./apiserver-etcd-client.crt ubuntu@\$${i}:
scp ./apiserver-etcd-client.key ubuntu@\$${i}:
ssh ubuntu@\$${i} -T << ENDSSH
sudo -E -s mkdir -p /etc/kubernetes/pki/etcd/
sudo -E -s mv ./etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
sudo -E -s mv ./apiserver-etcd-client.crt /etc/kubernetes/pki/apiserver-etcd-client.crt
sudo -E -s mv ./apiserver-etcd-client.key /etc/kubernetes/pki/apiserver-etcd-client.key
sudo -E -s chown -R root:root /etc/kubernetes/pki/
ENDSSH
done





mkdir -p /tmp/${control_plane1_ip}/
cat << EOFC > /tmp/${control_plane1_ip}/kubeadm-config.yaml

apiVersion: kubeadm.k8s.io/v1beta1
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: aws
---
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
imageRepository: vmware
kubernetesVersion: ${bootstrap_K8S_VERSION}
apiServer:
  certSANs:
  - "${lb_dns}"
  extraArgs:
    cloud-provider: aws
controllerManager:
  extraArgs:
    cloud-provider: aws
controlPlaneEndpoint: "${lb_dns}:443"
etcd:
    external:
        endpoints:
        - https://${etcd1_ip}:2379
        - https://${etcd2_ip}:2379
        - https://${etcd3_ip}:2379
        caFile: /etc/kubernetes/pki/etcd/ca.crt
        certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
        keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
networking:
    # This CIDR is a calico default. Substitute or remove for your CNI provider.
    podSubnet: "192.168.0.0/16"
EOFC
scp -r /tmp/${control_plane1_ip}/kubeadm-config.yaml ubuntu@${control_plane1_ip}:

ssh ubuntu@${control_plane1_ip} -t 'sudo -E -s kubeadm init --node-name=${control_plane1_internal_dns} --config kubeadm-config.yaml --ignore-preflight-errors=ImagePull'

for i in ca.crt ca.key sa.key sa.pub front-proxy-ca.crt front-proxy-ca.key; do
    ssh ubuntu@${control_plane1_ip} "sudo cat /etc/kubernetes/pki/\$${i}" > ./\$${i}
done

JOIN_COMMAND=\$(ssh ubuntu@${control_plane1_ip} -t 'sudo -E -s kubeadm token create --ttl 10m --print-join-command')

echo \$JOIN_COMMAND

for i in ${control_plane2_ip} ${control_plane3_ip}; do
    scp ./ca.crt ubuntu@\$${i}:
    scp ./ca.key ubuntu@\$${i}:
    scp ./sa.key ubuntu@\$${i}:
    scp ./sa.pub ubuntu@\$${i}:
    scp ./front-proxy-ca.crt ubuntu@\$${i}:
    scp ./front-proxy-ca.key ubuntu@\$${i}:
    ssh ubuntu@\$${i} -T << ENDSSH
sudo -E -s mv ./ca.crt /etc/kubernetes/pki/
sudo -E -s mv ./ca.key /etc/kubernetes/pki/
sudo -E -s mv ./sa.pub /etc/kubernetes/pki/
sudo -E -s mv ./sa.key /etc/kubernetes/pki/
sudo -E -s mv ./front-proxy-ca.crt /etc/kubernetes/pki/
sudo -E -s mv ./front-proxy-ca.key /etc/kubernetes/pki/
sudo -E -s chown -R root:root /etc/kubernetes/pki/

ENDSSH
done

echo 'ssh ubuntu@${control_plane2_ip} "sudo -s \$${JOIN_COMMAND} --node-name=${control_plane2_internal_dns} --experimental-control-plane --ignore-preflight-errors=ImagePull"'
echo 'ssh ubuntu@${control_plane3_ip} "sudo -s \$${JOIN_COMMAND} --node-name=${control_plane3_internal_dns} --experimental-control-plane --ignore-preflight-errors=ImagePull"'

ssh ubuntu@${control_plane1_ip} -T << ENDSSH
mkdir -p /home/ubuntu/.kube
sudo -E -s cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo -E -s chown ubuntu:ubuntu /home/ubuntu/.kube/config
kubectl -n kube-system set image deployment/coredns \*=vmware/coredns:${bootstrap_COREDNS}_vmware.1
sleep 3
kubectl apply -f https://docs.projectcalico.org/v3.6/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
ENDSSH