[bastion]
127.0.0.1   ansible_connection=local

[master]
${cp1_ip}
${cp2_ip}
${cp3_ip}

[node]
${wk1_ip}
${wk2_ip}
${wk3_ip}
${wk4_ip}
${wk5_ip}