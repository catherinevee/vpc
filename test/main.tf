# Test configuration for the EC2 module

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Test: Basic EC2 Instance
module "test_basic_ec2" {
  source = "../"

  instance_name = "test-basic-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678" # Replace with your subnet ID for testing

  # Use latest Amazon Linux 2 AMI
  use_latest_ami = true
  ami_type       = "amazon_linux_2"

  # Create security group with minimal access
  create_security_group = true
  vpc_id                = "vpc-12345678" # Replace with your VPC ID for testing

  security_group_ingress_rules = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
      security_groups = []
      self            = false
    }
  ]

  # Root block device configuration
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  ]

  tags = {
    Environment = "test"
    Project     = "terraform-ec2-module-test"
    Owner       = "devops"
  }
}

# Test: EC2 Instance with Launch Template
module "test_launch_template" {
  source = "../"

  instance_name = "test-lt-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678" # Replace with your subnet ID for testing

  # Use launch template
  use_launch_template = true

  # Create security group
  create_security_group = true
  vpc_id                = "vpc-12345678" # Replace with your VPC ID for testing

  security_group_ingress_rules = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
      security_groups = []
      self            = false
    }
  ]

  # Block device mappings for launch template
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 25
        volume_type           = "gp3"
      }
    }
  ]

  tags = {
    Environment = "test"
    Project     = "terraform-ec2-module-test"
    Owner       = "devops"
  }
}

# Test: EC2 Instance with IAM Role
module "test_iam_ec2" {
  source = "../"

  instance_name = "test-iam-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678" # Replace with your subnet ID for testing

  # Create IAM role
  create_iam_role = true
  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ]
      Resource = "*"
    }
  ]

  # Use latest Amazon Linux 2 AMI
  use_latest_ami = true
  ami_type       = "amazon_linux_2"

  # Create security group
  create_security_group = true
  vpc_id                = "vpc-12345678" # Replace with your VPC ID for testing

  security_group_ingress_rules = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
      security_groups = []
      self            = false
    }
  ]

  tags = {
    Environment = "test"
    Project     = "terraform-ec2-module-test"
    Owner       = "devops"
  }
}

# Test: Multiple EC2 Instances
module "test_multiple_ec2" {
  source = "../"

  instance_name = "test-multi-instance"
  instance_count = 2
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678" # Replace with your subnet ID for testing

  # Use latest Amazon Linux 2 AMI
  use_latest_ami = true
  ami_type       = "amazon_linux_2"

  # Create security group
  create_security_group = true
  vpc_id                = "vpc-12345678" # Replace with your VPC ID for testing

  security_group_ingress_rules = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["10.0.0.0/8"]
      security_groups = []
      self            = false
    }
  ]

  # Root block device configuration
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  ]

  tags = {
    Environment = "test"
    Project     = "terraform-ec2-module-test"
    Owner       = "devops"
  }
} 