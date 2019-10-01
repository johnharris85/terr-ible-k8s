######### CONTROL-PLANE ##############
module "control_plane" {
  name                 = "control-plane"
  source               = "terraform-aws-modules/autoscaling/aws"
  version = "~>2.0"
  asg_name             = "control-plane"
  image_id             = "${var.image_id}"
  instance_type        = "t2.medium"
  key_name             = "kubeadm-ec2"
  health_check_type    = "EC2"
  iam_instance_profile = "${aws_iam_instance_profile.control_plane_provider.name}"
  security_groups      = ["${aws_security_group.control-plane.id}"]
  vpc_zone_identifier  = "${module.main_vpc.private_subnets}"
  min_size             = 3
  max_size             = 6
  desired_capacity     = 3

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  tags_as_map = {
    Terraform                      = "true"
    Role                           = "control-plane"
    "kubernetes.io/cluster/jh-k8s" = "owned"
  }
}

resource "aws_security_group" "control-plane" {
  name        = "control-plane"
  description = "control-plane"
  vpc_id      = "${module.main_vpc.vpc_id}"
}

resource "aws_security_group_rule" "controlplane-controlplane" {
  description              = "controlplane to controlplane"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.control-plane.id}"
  security_group_id        = "${aws_security_group.control-plane.id}"
}

resource "aws_security_group_rule" "workers-controlplane" {
  description              = "worker to controlplane"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.workers.id}"
  security_group_id        = "${aws_security_group.control-plane.id}"
}

resource "aws_security_group_rule" "controlplane-outbound" {
  description       = "outbound all"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.control-plane.id}"
}

resource "aws_security_group_rule" "bastion-in-controlplane" {
  description              = "ssh bastion in"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.control-plane.id}"
}

resource "aws_security_group_rule" "lb-controlplane" {
  description              = "lb to controlplane"
  type                     = "ingress"
  from_port                = "${var.api_instance_port}"
  to_port                  = "${var.api_instance_port}"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${aws_security_group.control-plane.id}"
}