terraform {
  source = "git::git@github.com:catherinevee/finops.git//vpc?ref=v1.0.0"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name        = "vpc-${get_env("TF_VAR_environment", "dev")}"
  environment = get_env("TF_VAR_environment", "dev")

  vpc_config = {
    cidr_block           = "10.0.0.0/16"
    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true
    enable_dns_support   = true
  }

  subnet_config = {
    azs              = ["us-west-2a", "us-west-2b"]
    private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  }

  tags = {
    Project     = "vpc-infrastructure"
    Environment = get_env("TF_VAR_environment", "dev")
    ManagedBy   = "terragrunt"
  }
}
