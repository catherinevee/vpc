variables {
  name = "test-vpc"
  environment = "dev"
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    enable_dns_support = true
  }
  subnet_config = {
    azs = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  }
  tags = {
    Project = "test"
    Environment = "dev"
  }
}

run "verify_vpc_creation" {
  command = plan

  assert {
    condition = length(aws_vpc.this) > 0
    error_message = "VPC was not created"
  }

  assert {
    condition = length(aws_subnet.private) == 2
    error_message = "Private subnets were not created correctly"
  }

  assert {
    condition = length(aws_subnet.public) == 2
    error_message = "Public subnets were not created correctly"
  }
}
