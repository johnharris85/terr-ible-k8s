---
all:
  vars:
    kubernetes_version: v1.14.3
    cni_version: 0.7.5
    docker_version: '5:18.09.5~3-0~ubuntu-{{ ansible_distribution_release | lower }}'
    cri_tools_version: 1.12.0
    coredns_version: v1.3.1
    etcd_version: v3.3.10
    pause_version: 3.1
    cluster_fqdn: ${lb_fqdn}
    cluster_name: jh-k8s