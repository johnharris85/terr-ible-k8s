######### ETCD ##############
module "etcd" {
  name                = "etcd"
  source              = "terraform-aws-modules/autoscaling/aws"
  version = "~>2.0"
  asg_name            = "etcd"
  image_id            = "${var.image_id}"
  instance_type       = "t2.medium"
  key_name            = "kubeadm-ec2"
  health_check_type   = "EC2"
  security_groups     = ["${aws_security_group.etcd.id}"]
  vpc_zone_identifier = "${module.main_vpc.private_subnets}"
  # user_data           = "${data.template_file.user_data_etcd.rendered}"
  min_size            = 3
  max_size            = 6
  desired_capacity    = 3

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  tags_as_map = {
    Terraform = "true"
    Role      = "etcd"
  }
}

# data "template_file" "user_data_etcd" {
#   template = "${file("${path.module}/templates/etcd-userdata")}"

#   vars {
#     bootstrap_docker_version = "${var.bootstrap_docker_version}"
#     bootstrap_K8S_VERSION    = "${var.bootstrap_K8S_VERSION}"
#     bootstrap_CNI_VERSION    = "${var.bootstrap_CNI_VERSION}"
#     bootstrap_CRI_TOOLS      = "${var.bootstrap_CRI_TOOLS}"
#     bootstrap_COREDNS        = "${var.bootstrap_COREDNS}"
#     bootstrap_ETCD           = "${var.bootstrap_ETCD}"
#     bootstrap_PAUSE          = "${var.bootstrap_PAUSE}"
#   }
# }

resource "aws_security_group" "etcd" {
  name        = "etcd"
  description = "etcd"
  vpc_id      = "${module.main_vpc.vpc_id}"
}

resource "aws_security_group_rule" "etcd-etcd" {
  description              = "etcd to etcd"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.etcd.id}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

resource "aws_security_group_rule" "controlplane-etcd" {
  description              = "controlplane to etcd"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.control-plane.id}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

resource "aws_security_group_rule" "etcd-outbound" {
  description       = "outbound all"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.etcd.id}"
}

resource "aws_security_group_rule" "bastion-in-etcd" {
  description              = "ssh bastion in"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.etcd.id}"
}

# data "template_file" "bastion_setup_etcd" {
#   template = "${file("${path.module}/templates/bastion-setup-etcd.tpl")}"

#   vars {
#     etcd1_ip              = "${data.aws_instances.etcd.private_ips[0]}"
#     etcd2_ip              = "${data.aws_instances.etcd.private_ips[1]}"
#     etcd3_ip              = "${data.aws_instances.etcd.private_ips[2]}"
#     bootstrap_K8S_VERSION = "${var.bootstrap_K8S_VERSION}"
#   }
# }
