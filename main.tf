# TODO:
# - ELB / NLB?
# - IAM Roles / cloudprovider
# - Velero setup
# - Other?

######### VPC ##############

module "main_vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~>1.0"
  name               = "${var.main_vpc_name}"
  cidr               = "${var.main_vpc_cidr}"
  azs                = "${var.main_vpc_azs}"
  private_subnets    = "${var.main_vpc_private_subnets}"
  public_subnets     = "${var.main_vpc_public_subnets}"
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_s3_endpoint = true

  public_route_table_tags = {
    "kubernetes.io/cluster/jh-k8s" = "owned"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/jh-k8s" = "owned"
  }

  vpc_tags = {
    "kubernetes.io/cluster/jh-k8s" = "owned"
  }
}

data "aws_instances" "controlplane" {
  depends_on = ["module.control_plane"]

  instance_tags = {
    Role = "control-plane"
  }

  instance_state_names = ["running"]
}

data "aws_instance" "controlplane1" {
  depends_on = ["module.control_plane"]

  instance_id = "${data.aws_instances.controlplane.ids[0]}"
}

data "aws_instance" "controlplane2" {
  depends_on = ["module.control_plane"]

  instance_id = "${data.aws_instances.controlplane.ids[1]}"
}

data "aws_instance" "controlplane3" {
  depends_on = ["module.control_plane"]

  instance_id = "${data.aws_instances.controlplane.ids[2]}"
}

data "aws_instances" "etcd" {
  depends_on = ["module.etcd"]

  instance_tags = {
    Role = "etcd"
  }

  instance_state_names = ["running"]
}

data "aws_instances" "workers" {
  depends_on = ["module.workers"]

  instance_tags = {
    Role = "workers"
  }

  instance_state_names = ["running"]
}

data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    cp1_ip   = "${data.aws_instance.controlplane1.private_ip}"
    cp2_ip   = "${data.aws_instance.controlplane2.private_ip}"
    cp3_ip   = "${data.aws_instance.controlplane3.private_ip}"
    wk1_ip   = "${data.aws_instances.workers.private_ips[0]}"
    wk2_ip   = "${data.aws_instances.workers.private_ips[1]}"
    wk3_ip   = "${data.aws_instances.workers.private_ips[2]}"
    wk4_ip   = "${data.aws_instances.workers.private_ips[3]}"
    wk5_ip   = "${data.aws_instances.workers.private_ips[4]}"
  }
}

data "template_file" "extra_vars" {
  template = "${file("${path.module}/templates/extra-vars.tpl")}"

  vars {
    lb_fqdn           = "${module.elb_control_plane.this_elb_dns_name}"
    cluster_name      = "${var.cluster_name}"
    api_lb_port       = "${var.api_lb_port}"
    api_instance_port = "${var.api_instance_port}"
    pod_cidr = "${var.pod_cidr}"
    networking = "${var.networking}"
  }
}