#!/bin/bash 

set -ex

# Update HOST0, HOST1, and HOST2 with the IPs or resolvable names of your hosts
HOST0=${worker1_ip}
HOST1=${worker2_ip}
HOST2=${worker3_ip}

ETCDHOSTS=($${HOST0} $${HOST1} $${HOST2})
NAMES=("infra0" "infra1" "infra2")

ssh ubuntu@$${HOST0} 'sudo -E -s kubeadm init phase certs etcd-ca'
sleep 5
ssh ubuntu@$${HOST0} 'sudo cat /etc/kubernetes/pki/etcd/ca.key' > ./ca.key
ssh ubuntu@$${HOST0} 'sudo cat /etc/kubernetes/pki/etcd/ca.crt' > ./ca.crt

for i in "$${!ETCDHOSTS[@]}"; do
HOST=$${ETCDHOSTS[$i]}
mkdir -p /tmp/$${HOST}/
ssh-keyscan -H $${HOST} >> ~/.ssh/known_hosts
NAME=$${NAMES[$i]}
cat << EOF > /tmp/$${HOST}/etcd-config.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
imageRepository: vmware
etcd:
    local:
        serverCertSANs:
        - "$${HOST}"
        peerCertSANs:
        - "$${HOST}"
        extraArgs:
            initial-cluster: $${NAMES[0]}=https://$${ETCDHOSTS[0]}:2380,$${NAMES[1]}=https://$${ETCDHOSTS[1]}:2380,$${NAMES[2]}=https://$${ETCDHOSTS[2]}:2380
            initial-cluster-state: new
            name: $${NAME}
            listen-peer-urls: https://$${HOST}:2380
            listen-client-urls: https://$${HOST}:2379
            advertise-client-urls: https://$${HOST}:2379
            initial-advertise-peer-urls: https://$${HOST}:2380
EOF
scp -r /tmp/$${HOST}/* ubuntu@$${HOST}:
scp ./ca.crt ubuntu@$${HOST}:
scp ./ca.key ubuntu@$${HOST}:
ssh ubuntu@$${HOST} -t 'sudo -E -s ./setup-node'
done