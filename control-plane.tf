######### CONTROL-PLANE ##############
module "control_plane" {
  name                 = "control-plane"
  source               = "terraform-aws-modules/autoscaling/aws"
  asg_name             = "control-plane"
  image_id             = "ami-005bdb005fb00e791"
  instance_type        = "t2.medium"
  key_name             = "kubeadm-ec2"
  health_check_type    = "EC2"
  iam_instance_profile = "${aws_iam_instance_profile.control_plane_provider.name}"
  security_groups      = ["${aws_security_group.control-plane.id}"]
  vpc_zone_identifier  = "${module.main_vpc.private_subnets}"
  # user_data            = "${data.template_file.user_data_control_plane.rendered}"
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

# data "template_file" "user_data_control_plane" {
#   template = "${file("${path.module}/templates/control-plane-userdata")}"

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
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.lb.id}"
  security_group_id        = "${aws_security_group.control-plane.id}"
}

# data "template_file" "bastion_setup_control_plane" {
#   template = "${file("${path.module}/templates/bastion-setup-control-plane.tpl")}"

#   vars {
#     control_plane1_ip           = "${data.aws_instance.controlplane1.private_ip}"
#     control_plane2_ip           = "${data.aws_instance.controlplane2.private_ip}"
#     control_plane3_ip           = "${data.aws_instance.controlplane3.private_ip}"
#     control_plane1_internal_dns = "${data.aws_instance.controlplane1.private_dns}"
#     control_plane2_internal_dns = "${data.aws_instance.controlplane2.private_dns}"
#     control_plane3_internal_dns = "${data.aws_instance.controlplane3.private_dns}"
#     etcd1_ip                    = "${data.aws_instances.etcd.private_ips[0]}"
#     etcd2_ip                    = "${data.aws_instances.etcd.private_ips[1]}"
#     etcd3_ip                    = "${data.aws_instances.etcd.private_ips[2]}"
#     bootstrap_K8S_VERSION       = "${var.bootstrap_K8S_VERSION}"
#     bootstrap_COREDNS           = "${var.bootstrap_COREDNS}"
#     lb_dns                      = "${module.elb_control_plane.this_elb_dns_name}"
#   }
# }
