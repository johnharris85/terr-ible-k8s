output "bastion_ip" {
  value = "ssh -A ubuntu@${data.aws_instances.bastion.public_ips[0]}"
}