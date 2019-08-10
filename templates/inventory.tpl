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