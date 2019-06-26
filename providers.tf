provider "aws" {
  version = ">= 1.22.0"
  region  = "us-west-2"
}

provider "local" {
  version = ">= 1.1"
}

provider "null" {
  version = ">= 2.0"
}

provider "template" {
  version = ">= 2.0"
}