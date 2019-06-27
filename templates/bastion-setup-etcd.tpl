#!/bin/bash

set -xe

ssh-keyscan -H ${etcd1_ip} >> ~/.ssh/known_hosts
sleep 2
ssh ubuntu@${etcd1_ip} 'sudo -E -s kubeadm init phase certs etcd-ca'
sleep 3
ssh ubuntu@${etcd1_ip} 'sudo cat /etc/kubernetes/pki/etcd/ca.key' > ./etcd-ca.key
ssh ubuntu@${etcd1_ip} 'sudo cat /etc/kubernetes/pki/etcd/ca.crt' > ./etcd-ca.crt


mkdir -p /tmp/${etcd1_ip}/
mkdir -p /tmp/${etcd2_ip}/
mkdir -p /tmp/${etcd3_ip}/

cat << EOFI > /tmp/${etcd1_ip}/etcd-config.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
imageRepository: vmware
kubernetesVersion: ${bootstrap_K8S_VERSION}
etcd:
    local:
        serverCertSANs:
        - "${etcd1_ip}"
        peerCertSANs:
        - "${etcd1_ip}"
        extraArgs:
            initial-cluster: infra0=https://${etcd1_ip}:2380,infra1=https://${etcd2_ip}:2380,infra2=https://${etcd3_ip}:2380
            initial-cluster-state: new
            name: infra0
            listen-peer-urls: https://${etcd1_ip}:2380
            listen-client-urls: https://${etcd1_ip}:2379
            advertise-client-urls: https://${etcd1_ip}:2379
            initial-advertise-peer-urls: https://${etcd1_ip}:2380
EOFI

cat << EOFI > /tmp/${etcd2_ip}/etcd-config.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
imageRepository: vmware
kubernetesVersion: ${bootstrap_K8S_VERSION}
etcd:
    local:
        serverCertSANs:
        - "${etcd2_ip}"
        peerCertSANs:
        - "${etcd2_ip}"
        extraArgs:
            initial-cluster: infra0=https://${etcd1_ip}:2380,infra1=https://${etcd2_ip}:2380,infra2=https://${etcd3_ip}:2380
            initial-cluster-state: new
            name: infra1
            listen-peer-urls: https://${etcd2_ip}:2380
            listen-client-urls: https://${etcd2_ip}:2379
            advertise-client-urls: https://${etcd2_ip}:2379
            initial-advertise-peer-urls: https://${etcd2_ip}:2380
EOFI

cat << EOFI > /tmp/${etcd3_ip}/etcd-config.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
imageRepository: vmware
kubernetesVersion: ${bootstrap_K8S_VERSION}
etcd:
    local:
        serverCertSANs:
        - "${etcd3_ip}"
        peerCertSANs:
        - "${etcd3_ip}"
        extraArgs:
            initial-cluster: infra0=https://${etcd1_ip}:2380,infra1=https://${etcd2_ip}:2380,infra2=https://${etcd3_ip}:2380
            initial-cluster-state: new
            name: infra2
            listen-peer-urls: https://${etcd3_ip}:2380
            listen-client-urls: https://${etcd3_ip}:2379
            advertise-client-urls: https://${etcd3_ip}:2379
            initial-advertise-peer-urls: https://${etcd3_ip}:2380
EOFI

for i in ${etcd1_ip} ${etcd2_ip} ${etcd3_ip}; do
ssh-keyscan -H \$${i} >> ~/.ssh/known_hosts
scp -r /tmp/\$${i}/etcd-config.yaml ubuntu@\$${i}:
scp ./etcd-ca.crt ubuntu@\$${i}:
scp ./etcd-ca.key ubuntu@\$${i}:
ssh ubuntu@\$${i} -T << ENDSSH 
sudo -E -s mkdir -p /etc/kubernetes/pki/etcd/
sudo -E -s mv etcd-ca.crt /etc/kubernetes/pki/etcd/ca.crt
sudo -E -s mv etcd-ca.key /etc/kubernetes/pki/etcd/ca.key
sudo -E -s chown -R root:root /etc/kubernetes/pki/
sudo -E -s kubeadm init phase certs etcd-server --config=etcd-config.yaml
sudo -E -s kubeadm init phase certs etcd-peer --config=etcd-config.yaml
sudo -E -s kubeadm init phase certs etcd-healthcheck-client --config=etcd-config.yaml
sudo -E -s kubeadm init phase certs apiserver-etcd-client --config=etcd-config.yaml
sudo -E -s kubeadm init phase etcd local --config=etcd-config.yaml
ENDSSH
done

sleep 3

ssh ubuntu@${etcd1_ip} 'sudo cat /etc/kubernetes/pki/apiserver-etcd-client.key' > ./apiserver-etcd-client.key
ssh ubuntu@${etcd1_ip} 'sudo cat /etc/kubernetes/pki/apiserver-etcd-client.crt' > ./apiserver-etcd-client.crt

# docker run --rm -it --net host -v /etc/kubernetes:/etc/kubernetes k8s.gcr.io/etcd:3.3.10 etcdctl --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --ca-file /etc/kubernetes/pki/etcd/ca.crt --endpoints https://$(curl http://169.254.169.254/latest/meta-data/local-ipv4):2379 cluster-health