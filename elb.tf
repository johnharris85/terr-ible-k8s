######### CONTROL-PLANE ##############
module "elb_control_plane" {
  source  = "terraform-aws-modules/elb/aws"

  name = "elb-control-plane-${var.cluster_name}"

  subnets         = module.main_vpc.public_subnets
  security_groups = [aws_security_group.lb.id]
  internal        = false

  listener = [
    {
      instance_port     = var.api_instance_port
      instance_protocol = "TCP"
      lb_port           = var.api_lb_port
      lb_protocol       = "TCP"
    },
  ]

  health_check = {
      target              = "SSL:${var.api_instance_port}"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    }
  

  // ELB attachments
  number_of_instances = 3
  instances           = data.aws_instances.controlplane.ids

  tags = {
    Terraform = "true"
    Role      = "lb-${var.cluster_name}"
  }
}

resource "aws_security_group" "lb" {
  name        = "lb-${var.cluster_name}"
  description = "lb"
  vpc_id      = module.main_vpc.vpc_id
}

resource "aws_security_group_rule" "lb-outbound" {
  description       = "outbound all"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

resource "aws_security_group_rule" "lb-in-controlplane" {
  description       = "controlplane-lb in"
  type              = "ingress"
  from_port         = var.api_lb_port
  to_port           = var.api_lb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lb.id
}

