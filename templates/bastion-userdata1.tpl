#!/bin/bash

set -ex

cat << EOF >> /home/ubuntu/.profile
alias cp1='ssh ubuntu@${cp1_ip}'
alias cp2='ssh ubuntu@${cp2_ip}'
alias cp3='ssh ubuntu@${cp3_ip}'
alias etcd1='ssh ubuntu@${etcd1_ip}'
alias etcd2='ssh ubuntu@${etcd2_ip}'
alias etcd3='ssh ubuntu@${etcd3_ip}'
alias wk1='ssh ubuntu@${wk1_ip}'
alias wk2='ssh ubuntu@${wk2_ip}'
alias wk3='ssh ubuntu@${wk3_ip}'
EOF

cat << EOFA >> /home/ubuntu/setup-etcd.sh
${etcd_setup_data}
EOFA

cat << EOFB >> /home/ubuntu/setup-control-plane.sh
${control_plane_setup_data}
EOFB

# cat << EOFC >> /home/ubuntu/setup-workers.sh
# ${workers_setup_data}
# EOFC

sleep 5

chmod +x /home/ubuntu/setup-etcd.sh
chmod +x /home/ubuntu/setup-control-plane.sh
# chmod +x /home/ubuntu/setup-workers.sh
