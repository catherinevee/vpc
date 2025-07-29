# Test configuration for the VPC module

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Test the VPC module with minimal configuration
module "vpc_test" {
  source = "../"

  vpc_name = "test-vpc"
  vpc_cidr = "10.1.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnets    = ["10.1.11.0/24", "10.1.12.0/24"]

  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Environment = "test"
    Project     = "vpc-module-test"
  }
} 