# Example usage of the custom VPC module

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Use the custom VPC module
module "vpc" {
  source = "../"

  vpc_name = "example-vpc"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnets   = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Environment = "example"
    Project     = "terraform-vpc-module"
    Owner       = "devops"
  }
}

# Example: Create an EC2 instance in a public subnet
resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI (us-east-1)
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_ids[0]

  vpc_security_group_ids = [module.vpc.default_security_group_id]

  tags = {
    Name = "example-instance"
  }
}

# Example: Create a DB subnet group for RDS
resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet-group"
  subnet_ids = module.vpc.database_subnet_ids

  tags = {
    Name = "example-db-subnet-group"
  }
} 