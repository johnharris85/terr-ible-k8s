#!/bin/bash

set -xe

export DEBIAN_FRONTEND=noninteractive

mkdir -p /bootstrap
cd /bootstrap
git clone https://github.com/johnharris85/terr-ible-k8s.git 
cd terr-ible-k8s

cat << EOF >> /bootstrap/inventory.ini
${inventory_file_content}
EOF

cat << EOF >> /bootstrap/extra_vars.yaml
${extra_vars_content}
EOF

apt-get install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get install -y ansible

cat << EOF >> /etc/ansible/ansible.cfg
[defaults]
host_key_checking = False
EOF