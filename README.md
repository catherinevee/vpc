# Custom VPC Terraform Module

A comprehensive Terraform module for creating AWS VPC infrastructure using the [HashiCorp AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest). This module follows Terraform and Infrastructure as Code best practices with comprehensive validation, security scanning, and CI/CD integration.

## Features

- **VPC Creation** with customizable CIDR blocks and advanced options
- **Internet Gateway** for public subnets
- **Public Subnets** with auto-assigned public IPs
- **Private Subnets** with NAT Gateway connectivity
- **Database Subnets** for RDS and other database services
- **Route Tables** with proper routing configuration
- **NAT Gateways** for private subnet internet access
- **Security Groups** with configurable rules
- **Comprehensive Tagging** support
- **IPv6 Support** with dual-stack networking
- **Instance Tenancy** options (default/dedicated)
- **IPAM Integration** for IP address management
- **Input Validation** with detailed error messages
- **Linting & Security Scanning** with TFLint and Checkov
- **CI/CD Integration** with GitHub Actions
- **Pre-commit Hooks** for code quality

## Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS Provider >= 4.0
- TFLint (optional, for linting)
- pre-commit (optional, for pre-commit hooks)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd vpc

# Install pre-commit hooks (optional)
pre-commit install

# Install dependencies
make install
```

### Basic Usage

```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Usage with Database Subnets

```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "production-vpc"
  vpc_cidr = "172.16.0.0/16"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  private_subnets    = ["172.16.11.0/24", "172.16.12.0/24", "172.16.13.0/24"]
  database_subnets   = ["172.16.21.0/24", "172.16.22.0/24", "172.16.23.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true  # Cost optimization
  create_igw         = true

  # Custom security group rules
  default_security_group_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
      description = "SSH access from VPC"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    }
  ]

  tags = {
    Environment = "production"
    Project     = "ecommerce"
    Owner       = "devops-team"
  }
}
```

### IPv6 Enabled VPC

```hcl
module "vpc" {
  source = "./vpc"

  vpc_name = "ipv6-vpc"
  vpc_cidr = "10.0.0.0/16"
  
  # Enable IPv6
  enable_ipv6 = true
  ipv6_cidr_block = "2001:db8::/56"

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  
  # IPv6 CIDR blocks for subnets
  public_subnet_ipv6_cidrs  = ["2001:db8::/64", "2001:db8:0:1::/64", "2001:db8:0:2::/64"]
  private_subnet_ipv6_cidrs = ["2001:db8:0:10::/64", "2001:db8:0:11::/64", "2001:db8:0:12::/64"]

  enable_nat_gateway = true
  create_igw         = true

  tags = {
    Environment = "production"
    Project     = "dual-stack"
  }
}
```

## Development Workflow

### Using Makefile

```bash
# Initialize the project
make init

# Format and validate code
make dev

# Run full production checks
make prod

# Create and apply changes
make plan
make apply

# Clean up
make clean
```

### Using Pre-commit Hooks

```bash
# Install pre-commit hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

### Using Terraform Commands

```bash
# Initialize
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy resources
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| vpc_name | Name of the VPC | `string` | `"custom-vpc"` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| instance_tenancy | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| ipv4_ipam_pool_id | The ID of an IPv4 IPAM pool for allocating VPC CIDR | `string` | `null` | no |
| ipv4_netmask_length | The netmask length of the IPv4 CIDR | `number` | `null` | no |
| ipv6_cidr_block | The IPv6 CIDR block for the VPC | `string` | `null` | no |
| ipv6_ipam_pool_id | The ID of an IPv6 IPAM pool for allocating VPC CIDR | `string` | `null` | no |
| ipv6_netmask_length | The netmask length of the IPv6 CIDR | `number` | `null` | no |
| ipv6_cidr_block_network_border_group | The location from which we advertise the IPv6 CIDR | `string` | `null` | no |
| enable_ipv6 | Should be true to enable IPv6 support in the VPC and subnets | `bool` | `false` | no |
| public_subnet_ipv6_cidrs | List of IPv6 CIDR blocks for public subnets | `list(string)` | `[]` | no |
| private_subnet_ipv6_cidrs | List of IPv6 CIDR blocks for private subnets | `list(string)` | `[]` | no |
| database_subnet_ipv6_cidrs | List of IPv6 CIDR blocks for database subnets | `list(string)` | `[]` | no |
| availability_zones | List of availability zones | `list(string)` | `["us-east-1a", "us-east-1b", "us-east-1c"]` | no |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | no |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]` | no |
| database_subnets | List of database subnet CIDR blocks | `list(string)` | `[]` | no |
| map_public_ip_on_launch | Should be true if you want to auto-assign public IP on launch | `bool` | `true` | no |
| create_igw | Controls if an Internet Gateway is created for public subnets | `bool` | `true` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways for each of your private networks | `bool` | `true` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all private networks | `bool` | `false` | no |
| create_default_security_group | Controls if default security group should be created | `bool` | `true` | no |
| default_security_group_ingress_rules | List of ingress rules for the default security group | `list(object)` | See variables.tf | no |
| default_security_group_egress_rules | List of egress rules for the default security group | `list(object)` | See variables.tf | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| vpc_tags | Additional tags for the VPC | `map(string)` | `{}` | no |
| public_subnet_tags | Additional tags for the public subnets | `map(string)` | `{}` | no |
| private_subnet_tags | Additional tags for the private subnets | `map(string)` | `{}` | no |
| database_subnet_tags | Additional tags for the database subnets | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_arn | The ARN of the VPC |
| internet_gateway_id | The ID of the Internet Gateway |
| public_subnet_ids | List of IDs of public subnets |
| private_subnet_ids | List of IDs of private subnets |
| database_subnet_ids | List of IDs of database subnets |
| public_subnet_arns | List of ARNs of public subnets |
| private_subnet_arns | List of ARNs of private subnets |
| database_subnet_arns | List of ARNs of database subnets |
| public_route_table_ids | List of IDs of public route tables |
| private_route_table_ids | List of IDs of private route tables |
| nat_gateway_ids | List of NAT Gateway IDs |
| nat_public_ips | List of public Elastic IPs created for NAT Gateway |
| default_security_group_id | The ID of the security group created by default on VPC creation |
| availability_zones | List of availability zones used |
| vpc_main_route_table_id | The ID of the main route table associated with this VPC |
| vpc_ipv6_cidr_block | The IPv6 CIDR block of the VPC |
| vpc_ipv6_cidr_block_network_border_group | The IPv6 CIDR block network border group |
| vpc_ipv6_association_id | The association ID for the IPv6 CIDR block |
| public_subnet_ipv6_cidr_blocks | List of IPv6 CIDR blocks of public subnets |
| private_subnet_ipv6_cidr_blocks | List of IPv6 CIDR blocks of private subnets |
| database_subnet_ipv6_cidr_blocks | List of IPv6 CIDR blocks of database subnets |

## CI/CD Integration

This module includes GitHub Actions workflows for:

- **Automated Testing**: Terraform validation, formatting, and linting
- **Security Scanning**: Trivy vulnerability scanning
- **Pull Request Reviews**: Automated plan generation and review comments
- **Quality Gates**: Pre-commit hooks and automated checks

### GitHub Actions Workflow

The `.github/workflows/terraform.yml` file includes:

1. **Terraform Operations**:
   - Format checking
   - Validation
   - Linting with TFLint
   - Plan generation for PRs

2. **Security Scanning**:
   - Trivy vulnerability scanning
   - SARIF report generation

3. **Pull Request Integration**:
   - Automated comments with plan details
   - Status checks for quality gates

## Security Best Practices

This module implements several security best practices:

- **Input Validation**: Comprehensive validation rules for all variables
- **Security Groups**: Configurable security group rules with least privilege
- **Encryption**: Support for encrypted state storage
- **Access Control**: Proper IAM and security group configurations
- **Vulnerability Scanning**: Integrated security scanning in CI/CD

## Backend Configuration

The module includes example backend configurations for:

- **AWS S3**: With DynamoDB state locking and KMS encryption
- **Azure Blob Storage**: With Azure AD authentication
- **Google Cloud Storage**: With encryption
- **Local**: For development and testing

Configure your backend in `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "vpc/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## Testing

### Running Tests

```bash
# Run all tests
make test

# Run specific test directory
cd test && terraform init && terraform plan
```

### Test Structure

- `test/` - Contains test configurations
- `examples/` - Contains usage examples
- Automated testing via GitHub Actions

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## AWS Resources Created

This module creates the following AWS resources using the [HashiCorp AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest):

- `aws_vpc` - Virtual Private Cloud
- `aws_internet_gateway` - Internet Gateway for public subnets
- `aws_subnet` - Public, private, and database subnets
- `aws_route_table` - Route tables for public and private subnets
- `aws_route_table_association` - Associations between subnets and route tables
- `aws_route` - Routes for internet and NAT gateway access
- `aws_eip` - Elastic IPs for NAT gateways
- `aws_nat_gateway` - NAT gateways for private subnet internet access
- `aws_security_group` - Default security group
- `aws_security_group_rule` - Security group rules

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `make dev` to ensure code quality
5. Add tests if applicable
6. Submit a pull request

### Development Guidelines

- Follow Terraform best practices
- Use meaningful variable names and descriptions
- Add validation rules for all variables
- Include comprehensive documentation
- Write tests for new features
- Use pre-commit hooks for code quality

## License

This module is licensed under the MIT License. See LICENSE for full details.

## Support

For issues and questions, please open an issue in the repository.

## References

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [TFLint Documentation](https://github.com/terraform-linters/tflint)
- [Pre-commit Terraform Hooks](https://github.com/antonbabenko/pre-commit-terraform)