# Terraform Ansible Kubernetes

This project provides a lightweight way to standup HA Kubernetes clusters using Terraform, Ansible and Kubeadm on (initially) AWS.

## Provisioning

1. Clone the repo.
2. Modify `terraform.tfvars` as desired (if you fork this repo then you'll want to edit the `git_repo` variable at the very least).
3. Ensure you have a valid AWS credential setup and run `terraform apply`.
4. When complete the script will output the command to ssh into the bastion host.

## Kubernetes Cluster Deployment

1. SSH into the bastion node using the command from step 4 above.
2. Move into the `/bootstrap` directory.
3. Modify `extra_vars.yml` as desired.
4. Run `ansible-playbook -i inventory.ini -e @extra_vars.yml terr-ible-k8s/ansible/install.yml`.
5. When complete, kubectl on the bastion node should be available and setup to communicate with the cluster. The kubeconfig can be copied elsewhere from the `/home/ubuntu/.kube/config` file.

## Kubernetes Cluster Upgrade

_**Note:** Currently only tested with 1.13.x & 1.14.x_

1. SSH into the bastion node.
2. Move into the `/bootstrap` directory.
3. Either modify `extra_vars.yml` or add override `-e` flags in the following step for desired configuration.
4. Run `ansible-playbook -i inventory.ini -e @extra_vars.yml terr-ible-k8s/ansible/upgrade.yml`.
5. When complete, verify that all nodes are upgraded by running `kubectl get nodes`.

## Troubleshooting

This project is provided with no support, but if you find bugs please file an issue. I'm no Terraform or Ansible expert either, so PRs also welcome.
