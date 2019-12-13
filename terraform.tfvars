# Main Changes
main_vpc_name = "jh-k8s"

main_vpc_cidr = "10.3.0.0/16"

main_vpc_private_subnets = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]

main_vpc_public_subnets = ["10.3.4.0/24", "10.3.5.0/24", "10.3.6.0/24"]

cluster_name = "jh-k8s"

main_vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]


# Secondary changes
main_vpc_aws_region = "us-west-2"

bootstrap_docker_version = "18.09.4"

bootstrap_K8S_VERSION = "v1.16.0"

bootstrap_CNI_VERSION = "0.7.5"

bootstrap_CRI_TOOLS = "1.16.0"

bootstrap_COREDNS = "v1.3.1"

bootstrap_ETCD = "v3.3.10"

bootstrap_PAUSE = "3.1"

git_repo = "https://github.com/johnharris85/terr-ible-k8s.git"

image_id = "ami-005bdb005fb00e791"

api_lb_port = "443"

api_instance_port = "6443"

pod_cidr = "192.168.0.0/16"

networking = "calico"
