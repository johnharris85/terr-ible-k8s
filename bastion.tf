######### BASTION ##############
module "bastion" {
  name                = "bastion"
  source              = "terraform-aws-modules/autoscaling/aws"
  asg_name            = "bastion"
  image_id            = "ami-005bdb005fb00e791"
  instance_type       = "t2.medium"
  key_name            = "kubeadm-ec2"
  health_check_type   = "EC2"
  security_groups     = ["${aws_security_group.bastion.id}"]
  vpc_zone_identifier = "${module.main_vpc.public_subnets}"
  user_data           = "${data.template_file.bastion-userdata.rendered}"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1

  recreate_asg_when_lc_changes = true

  root_block_device = [
    {
      volume_size = "8"
      volume_type = "gp2"
    },
  ]

  tags_as_map = {
    Terraform = "true"
    Role      = "bastion"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "bastion"
  vpc_id      = "${module.main_vpc.vpc_id}"
}

resource "aws_security_group_rule" "bastion-outbound" {
  description       = "outbound all"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion-ssh-in" {
  description       = "inbound ssh"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion.id}"
}

data "aws_instances" "bastion" {
  depends_on = ["module.bastion"]

  instance_tags = {
    Role = "bastion"
  }

  instance_state_names = ["running"]
}

data "template_file" "bastion-userdata" {
  template = "${file("${path.module}/templates/bastion-userdata.tpl")}"

  vars  {
    inventory_file_content = "${data.template_file.inventory.rendered}"
    extra_vars_content = "${data.template_file.extra_vars.rendered}"
  }
}