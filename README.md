# AWS EC2 Terraform Module

A comprehensive Terraform module for creating and managing AWS EC2 instances with support for launch templates, Auto Scaling Groups, IAM roles, security groups, and more.

## Features

- **Multiple AMI Support**: Amazon Linux 2, Ubuntu, and custom AMIs
- **Launch Templates**: Support for AWS Launch Templates with advanced configurations
- **Auto Scaling Groups**: Complete Auto Scaling Group setup with policies and CloudWatch alarms
- **IAM Integration**: Automatic IAM role and instance profile creation
- **Security Groups**: Flexible security group configuration with ingress/egress rules
- **Key Pairs**: SSH key pair management
- **Block Devices**: Configurable root and EBS block devices
- **User Data**: Support for user data scripts
- **Monitoring**: Detailed monitoring and metadata options
- **Tags**: Comprehensive tagging support
- **Multiple Instances**: Support for creating multiple instances with count

## Usage

### Basic EC2 Instance

```hcl
module "ec2" {
  source = "./ec2-module"

  instance_name = "my-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  # Use latest Amazon Linux 2 AMI
  use_latest_ami = true
  ami_type       = "amazon_linux_2"

  # Create security group
  create_security_group = true
  vpc_id                = "vpc-12345678"

  security_group_ingress_rules = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      self            = false
    }
  ]

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### EC2 Instance with Launch Template and Auto Scaling Group

```hcl
module "ec2_asg" {
  source = "./ec2-module"

  instance_name = "asg-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  # Use launch template
  use_launch_template = true

  # Create Auto Scaling Group
  create_autoscaling_group = true
  asg_desired_capacity     = 2
  asg_max_size             = 5
  asg_min_size             = 1
  asg_subnet_ids           = ["subnet-12345678", "subnet-87654321"]

  # Auto Scaling policies
  asg_policies = {
    scale_up = {
      name                   = "scale-up"
      adjustment_type        = "ChangeInCapacity"
      scaling_adjustment     = 1
      cooldown               = 300
    },
    scale_down = {
      name                   = "scale-down"
      adjustment_type        = "ChangeInCapacity"
      scaling_adjustment     = -1
      cooldown               = 300
    }
  }

  # CloudWatch alarms
  cloudwatch_alarms = {
    high_cpu = {
      alarm_name          = "high-cpu-utilization"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods  = 2
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      period              = 120
      statistic           = "Average"
      threshold           = 80
    }
  }

  create_security_group = true
  vpc_id                = "vpc-12345678"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### EC2 Instance with IAM Role

```hcl
module "ec2_iam" {
  source = "./ec2-module"

  instance_name = "iam-instance"
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  # Create IAM role
  create_iam_role = true
  iam_policy_statements = [
    {
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]

  create_security_group = true
  vpc_id                = "vpc-12345678"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Multiple EC2 Instances

```hcl
module "multiple_ec2" {
  source = "./ec2-module"

  instance_name = "multi-instance"
  instance_count = 3
  instance_type = "t3.micro"
  subnet_id     = "subnet-12345678"

  use_latest_ami = true
  ami_type       = "amazon_linux_2"

  create_security_group = true
  vpc_id                = "vpc-12345678"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

### EC2 Instance Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| instance_name | Name of the EC2 instance | `string` | `"ec2-instance"` | no |
| instance_count | Number of EC2 instances to create | `number` | `1` | no |
| instance_type | EC2 instance type | `string` | `"t3.micro"` | no |

### AMI Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ami_id | AMI ID to use for the EC2 instance | `string` | `null` | no |
| use_latest_ami | Whether to use the latest Amazon Linux 2 AMI | `bool` | `true` | no |
| ami_type | Type of AMI to use (amazon_linux_2, ubuntu, custom) | `string` | `"amazon_linux_2"` | no |
| custom_ami_id | Custom AMI ID to use | `string` | `null` | no |
| custom_ami_owner | Owner of the custom AMI | `string` | `"self"` | no |

### Network Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_id | VPC ID where the EC2 instance will be created | `string` | `null` | no |
| subnet_id | Subnet ID where the EC2 instance will be created | `string` | `null` | no |
| availability_zone | Availability zone for the EC2 instance | `string` | `null` | no |
| associate_public_ip_address | Whether to associate a public IP address | `bool` | `false` | no |
| private_ip | Private IP address for the EC2 instance | `string` | `null` | no |

### Security Group Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_security_group | Whether to create a security group for the EC2 instance | `bool` | `true` | no |
| security_group_ids | List of security group IDs to attach to the EC2 instance | `list(string)` | `[]` | no |
| security_group_ingress_rules | List of ingress rules for the security group | `list(object)` | See variables.tf | no |
| security_group_egress_rules | List of egress rules for the security group | `list(object)` | See variables.tf | no |

### Key Pair Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_key_pair | Whether to create a key pair for SSH access | `bool` | `false` | no |
| key_name | Name of the key pair to use for SSH access | `string` | `null` | no |
| public_key | Public key for the key pair | `string` | `null` | no |

### IAM Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_iam_role | Whether to create an IAM role for the EC2 instance | `bool` | `false` | no |
| iam_instance_profile_name | Name of the IAM instance profile to use | `string` | `null` | no |
| iam_policy_statements | List of IAM policy statements for the EC2 role | `list(object)` | `[]` | no |

### Launch Template Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| use_launch_template | Whether to use a launch template instead of direct EC2 instance | `bool` | `false` | no |
| block_device_mappings | List of block device mappings for the launch template | `list(object)` | `[]` | no |
| network_interfaces | List of network interfaces for the launch template | `list(object)` | `[]` | no |

### Auto Scaling Group Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_autoscaling_group | Whether to create an Auto Scaling Group | `bool` | `false` | no |
| asg_desired_capacity | Desired capacity for the Auto Scaling Group | `number` | `1` | no |
| asg_max_size | Maximum size for the Auto Scaling Group | `number` | `3` | no |
| asg_min_size | Minimum size for the Auto Scaling Group | `number` | `1` | no |
| asg_subnet_ids | List of subnet IDs for the Auto Scaling Group | `list(string)` | `[]` | no |
| asg_policies | Auto Scaling policies | `map(object)` | `{}` | no |
| cloudwatch_alarms | CloudWatch alarms for the Auto Scaling Group | `map(object)` | `{}` | no |

### Block Device Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| root_block_device | Root block device configuration | `list(object)` | See variables.tf | no |
| ebs_block_device | List of EBS block devices | `list(object)` | `[]` | no |
| ephemeral_block_device | List of ephemeral block devices | `list(object)` | `[]` | no |

### User Data Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_data | User data script for the EC2 instance | `string` | `null` | no |
| user_data_replace_on_change | Whether to replace the instance when user data changes | `bool` | `false` | no |

### Monitoring Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_detailed_monitoring | Whether to enable detailed monitoring | `bool` | `false` | no |
| metadata_options | Metadata options for the EC2 instance | `object` | `null` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

### EC2 Instance Outputs

| Name | Description |
|------|-------------|
| instance_ids | List of EC2 instance IDs |
| instance_arns | List of EC2 instance ARNs |
| instance_public_ips | List of public IP addresses of the EC2 instances |
| instance_private_ips | List of private IP addresses of the EC2 instances |
| instance_public_dns | List of public DNS names of the EC2 instances |
| instance_private_dns | List of private DNS names of the EC2 instances |

### Security Group Outputs

| Name | Description |
|------|-------------|
| security_group_id | ID of the security group created for the EC2 instance |
| security_group_arn | ARN of the security group created for the EC2 instance |
| security_group_name | Name of the security group created for the EC2 instance |

### Key Pair Outputs

| Name | Description |
|------|-------------|
| key_pair_id | ID of the key pair created for the EC2 instance |
| key_pair_name | Name of the key pair created for the EC2 instance |
| key_pair_fingerprint | Fingerprint of the key pair created for the EC2 instance |

### IAM Outputs

| Name | Description |
|------|-------------|
| iam_role_id | ID of the IAM role created for the EC2 instance |
| iam_role_arn | ARN of the IAM role created for the EC2 instance |
| iam_role_name | Name of the IAM role created for the EC2 instance |
| iam_instance_profile_id | ID of the IAM instance profile created for the EC2 instance |
| iam_instance_profile_arn | ARN of the IAM instance profile created for the EC2 instance |

### Launch Template Outputs

| Name | Description |
|------|-------------|
| launch_template_id | ID of the launch template created for the EC2 instance |
| launch_template_arn | ARN of the launch template created for the EC2 instance |
| launch_template_name | Name of the launch template created for the EC2 instance |

### Auto Scaling Group Outputs

| Name | Description |
|------|-------------|
| autoscaling_group_id | ID of the Auto Scaling Group created for the EC2 instance |
| autoscaling_group_arn | ARN of the Auto Scaling Group created for the EC2 instance |
| autoscaling_group_name | Name of the Auto Scaling Group created for the EC2 instance |
| autoscaling_group_desired_capacity | Desired capacity of the Auto Scaling Group created for the EC2 instance |
| autoscaling_group_max_size | Maximum size of the Auto Scaling Group created for the EC2 instance |
| autoscaling_group_min_size | Minimum size of the Auto Scaling Group created for the EC2 instance |

### Auto Scaling Policy Outputs

| Name | Description |
|------|-------------|
| autoscaling_policy_ids | IDs of the Auto Scaling policies created for the EC2 instance |
| autoscaling_policy_arns | ARNs of the Auto Scaling policies created for the EC2 instance |
| autoscaling_policy_names | Names of the Auto Scaling policies created for the EC2 instance |

### CloudWatch Alarm Outputs

| Name | Description |
|------|-------------|
| cloudwatch_alarm_ids | IDs of the CloudWatch alarms created for the EC2 instance |
| cloudwatch_alarm_arns | ARNs of the CloudWatch alarms created for the EC2 instance |
| cloudwatch_alarm_names | Names of the CloudWatch alarms created for the EC2 instance |

### AMI Outputs

| Name | Description |
|------|-------------|
| ami_id | AMI ID used for the EC2 instance |
| amazon_linux_2_ami_id | Amazon Linux 2 AMI ID |
| ubuntu_ami_id | Ubuntu AMI ID |
| custom_ami_id | Custom AMI ID |

## Examples

See the [examples](./examples) directory for complete usage examples:

- [Basic EC2 Instance](./examples/main.tf#L1-L50)
- [EC2 Instance with Key Pair](./examples/main.tf#L52-L85)
- [EC2 Instance with IAM Role](./examples/main.tf#L87-L130)
- [EC2 Instance with Launch Template and Auto Scaling Group](./examples/main.tf#L132-L250)
- [Multiple EC2 Instances](./examples/main.tf#L252-L290)

## Testing

Run the tests using the provided Makefile:

```bash
# Run all tests
make test

# Run examples
make examples

# Validate configuration
make validate

# Format code
make fmt

# Lint code
make lint
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite
6. Submit a pull request

## License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

For support and questions, please open an issue in the GitHub repository.

## Changelog

### Version 1.0.0
- Initial release
- Support for basic EC2 instances
- Launch template support
- Auto Scaling Group support
- IAM role integration
- Security group management
- Key pair management
- Multiple AMI support
- Comprehensive outputs