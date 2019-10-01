######### WORKERS ##############
module "workers" {
  name                = "workers"
  source              = "terraform-aws-modules/autoscaling/aws"
  version = "~>2.0"
  asg_name            = "workers"
  image_id            = "${var.image_id}"
  instance_type       = "t2.medium"
  key_name            = "kubeadm-ec2"
  health_check_type   = "EC2"
  iam_instance_profile = "${aws_iam_instance_profile.worker_node_provider.name}"
  security_groups     = ["${aws_security_group.workers.id}"]
  vpc_zone_identifier = "${module.main_vpc.private_subnets}"
  # user_data           = "${data.template_file.user_data_workers.rendered}"
  min_size            = 5
  max_size            = 8
  desired_capacity    = 5

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  tags_as_map = {
    Terraform = "true"
    Role      = "workers"
    "kubernetes.io/cluster/jh-k8s" = "owned"
  }
}

# data "template_file" "user_data_workers" {
#   template = "${file("${path.module}/templates/workers-userdata")}"

#   vars {
#     bootstrap_docker_version = "${var.bootstrap_docker_version}"
#     bootstrap_K8S_VERSION = "${var.bootstrap_K8S_VERSION}"
#     bootstrap_CNI_VERSION = "${var.bootstrap_CNI_VERSION}"
#     bootstrap_CRI_TOOLS = "${var.bootstrap_CRI_TOOLS}"
#     bootstrap_COREDNS = "${var.bootstrap_COREDNS}"
#     bootstrap_ETCD = "${var.bootstrap_ETCD}"
#     bootstrap_PAUSE = "${var.bootstrap_PAUSE}"
#   }
# }

resource "aws_security_group" "workers" {
  name        = "workers"
  description = "workers"
  vpc_id      = "${module.main_vpc.vpc_id}"
}

resource "aws_security_group_rule" "workers-workers" {
  description              = "worker to workers"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.workers.id}"
  security_group_id        = "${aws_security_group.workers.id}"
}

resource "aws_security_group_rule" "controlplane-workers" {
  description              = "controlplane to worker"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "all"
  source_security_group_id = "${aws_security_group.control-plane.id}"
  security_group_id        = "${aws_security_group.workers.id}"
}

resource "aws_security_group_rule" "workers-outbound" {
  description       = "outbound all"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.workers.id}"
}

resource "aws_security_group_rule" "bastion-in-workers" {
  description              = "ssh bastion in"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.bastion.id}"
  security_group_id        = "${aws_security_group.workers.id}"
}

# data "template_file" "bastion_setup_workers" {
#   template = "${file("${path.module}/templates/bastion-setup-workers.tpl")}"

#   vars {
#     worker1_ip = "${data.aws_instances.workers.private_ips[0]}"
#     worker2_ip = "${data.aws_instances.workers.private_ips[1]}"
#     worker3_ip = "${data.aws_instances.workers.private_ips[2]}"
#   }
# }
