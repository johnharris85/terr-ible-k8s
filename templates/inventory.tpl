[bastion]
127.0.0.1   ansible_connection=local

[etcd]
${etcd1_ip}
${etcd2_ip}
${etcd3_ip}

[master]
${cp1_ip}
${cp2_ip}
${cp3_ip}

[node]
${wk1_ip}
${wk2_ip}
${wk3_ip}




# [primary_master]
# 10.2.1.249   ansible_user=centos

# [etcd]
# 10.2.3.7 ansible_user=centos
# 10.2.1.45 ansible_user=centos
# 10.2.2.5 ansible_user=centos

# [masters]
# 10.2.1.249 ansible_user=centos
# 10.2.2.122 ansible_user=centos
# 10.2.3.36 ansible_user=centos

# [nodes]
# 10.2.3.190 ansible_user=centos
# 10.2.1.175 ansible_user=centos
# 10.2.2.158 ansible_user=centos



# etcd_interface: eth0 # Interface that etcd should bind
# kubernetes_common_primary_interface: eth0 # Interface that should be used to obtain the node's IP
# kubernetes_cni_plugin: calico # The CNI plugin to use

# # FQDN of the load balancer fronting the Kubernetes API servers.
# # This variable takes precedence over the kubernetes_common_api_ip variable.
# kubernetes_common_api_fqdn: "elb-control-plane-221803863.us-west-2.elb.amazonaws.com"

# kubernetes_common_kubeadm_config:
#   networking:
#     podSubnet: "192.168.0.0/16"