main_vpc_aws_region = "us-west-2"

main_vpc_name = "kubeadm-testing"

main_vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

main_vpc_cidr = "10.2.0.0/16"

main_vpc_private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]

main_vpc_public_subnets = ["10.2.4.0/24", "10.2.5.0/24", "10.2.6.0/24"]

bootstrap_docker_version = "18.09.4"

bootstrap_K8S_VERSION = "v1.14.3+vmware.1"

bootstrap_CNI_VERSION = "0.7.5"

bootstrap_CRI_TOOLS = "1.12.0"

bootstrap_COREDNS = "v1.3.1"

bootstrap_ETCD = "v3.3.10"

bootstrap_PAUSE = "3.1"
