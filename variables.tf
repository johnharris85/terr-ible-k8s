variable "main_vpc_aws_region" {
  type = "string"
}

variable "main_vpc_name" {
  type = "string"
}

variable "main_vpc_azs" {
  type = "list"
}

variable "main_vpc_cidr" {
  type = "string"
}

variable "main_vpc_private_subnets" {
  type = "list"
}

variable "main_vpc_public_subnets" {
  type = "list"
}

variable "bootstrap_docker_version" {
  type = "string"
}

variable "bootstrap_K8S_VERSION" {
  type = "string"
}

variable "bootstrap_CNI_VERSION" {
  type = "string"
}

variable "bootstrap_CRI_TOOLS" {
  type = "string"
}

variable "bootstrap_COREDNS" {
  type = "string"
}

variable "bootstrap_ETCD" {
  type = "string"
}

variable "bootstrap_PAUSE" {
  type = "string"
}

variable "git_repo" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "image_id" {
  type = "string"
}

variable "api_lb_port" {
  type = "string"
}

variable "api_instance_port" {
  type = "string"
}

variable "pod_cidr" {
  type = "string"
}

variable "networking" {
  type = "string"
}
