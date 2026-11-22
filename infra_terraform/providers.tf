terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
    helm = { source = "hashicorp/helm", version = "~> 2.17" }
  }
}
provider "aws" { region = var.aws_region }
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" { state = "available" }
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]
#   filter { name = "name"; values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] }
#   filter { name = "architecture"; values = ["x86_64"] }
}
