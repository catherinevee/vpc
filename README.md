# AWS VPC Infrastructure Module

A comprehensive Terraform module for creating AWS VPC infrastructure with integrated cloud resources including EKS, RDS, ElastiCache, Application Load Balancers, Lambda functions, and more.

## Features

- **Multi-tier VPC Architecture**: Public, private, database, ElastiCache, Redshift, and intra subnets
- **EKS Integration**: Complete EKS cluster with managed node groups and Fargate profiles
- **Database Services**: RDS instances with subnet groups and security configurations
- **Caching Layer**: ElastiCache clusters for Redis and Memcached
- **Load Balancing**: Application Load Balancers with target groups and listeners
- **Serverless Computing**: Lambda functions with VPC integration
- **Container Registry**: ECR repositories with lifecycle policies
- **Security**: Comprehensive security groups and network policies
- **Monitoring**: CloudWatch Container Insights, metrics server, and cluster autoscaler
- **Backup & Recovery**: Velero backup solution for Kubernetes resources
- **Network Policies**: Support for Calico and Cilium network policies

## Resource Map

| Resource Type | Service | Description |
|--------------|---------|-------------|
| VPC | AWS VPC | Main Virtual Private Cloud |
| Subnets | AWS VPC | Public, Private, Database, ElastiCache, and Redshift subnets |
| Internet Gateway | AWS VPC | Internet access for public subnets |
| NAT Gateway | AWS VPC | Internet access for private subnets |
| Route Tables | AWS VPC | Traffic routing rules for subnets |
| Security Groups | AWS VPC | Network security rules |
| EKS Cluster | AWS EKS | Managed Kubernetes cluster |
| EKS Node Groups | AWS EKS | EC2 instances for Kubernetes workloads |
| Application Load Balancer | AWS ELB | Load balancer for applications |
| RDS Instances | AWS RDS | Managed database instances |
| ElastiCache Clusters | AWS ElastiCache | In-memory caching |
| Lambda Functions | AWS Lambda | Serverless compute |
| ECR Repositories | AWS ECR | Container image registry |
| CloudWatch Logs | AWS CloudWatch | Log management and monitoring |
| IAM Roles | AWS IAM | Access control and permissions |

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS VPC Infrastructure                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Public    │    │   Public    │    │   Public    │         │
│  │   Subnets   │    │   Subnets   │    │   Subnets   │         │
│  │             │    │             │    │             │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │   ALB   │ │    │ │   ALB   │ │    │ │   ALB   │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Private   │    │   Private   │    │   Private   │         │
│  │   Subnets   │    │   Subnets   │    │   Subnets   │         │
│  │             │    │             │    │             │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │  EKS    │ │    │ │  EKS    │ │    │ │  EKS    │ │         │
│  │ │ Nodes   │ │    │ │ Nodes   │ │    │ │ Nodes   │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │ Lambda  │ │    │ │ Lambda  │ │    │ │ Lambda  │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                   │                   │               │
│         └───────────────────┼───────────────────┘               │
│                             │                                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  Database   │    │  Database   │    │  Database   │         │
│  │   Subnets   │    │   Subnets   │    │   Subnets   │         │
│  │             │    │             │    │             │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │   RDS   │ │    │ │   RDS   │ │    │ │   RDS   │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │ ElastiCache │    │ ElastiCache │    │ ElastiCache │         │
│  │   Subnets   │    │   Subnets   │    │   Subnets   │         │
│  │             │    │             │    │             │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │  Redis  │ │    │ │  Redis  │ │    │ │  Redis  │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │  Redshift   │    │  Redshift   │    │  Redshift   │         │
│  │   Subnets   │    │   Subnets   │    │   Subnets   │         │
│  │             │    │             │    │             │         │
│  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌─────────┐ │         │
│  │ │Redshift │ │    │ │Redshift │ │    │ │Redshift │ │         │
│  │ └─────────┘ │    │ └─────────┘ │    │ └─────────┘ │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "vpc_infrastructure" {
  source = "./vpc"

  name        = "my-app"
  environment = "dev"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true
    enable_dns_hostnames = true
    enable_dns_support   = true
  }

  # Subnet Configuration
  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  }

  # EKS Configuration
  eks_node_groups = {
    general = {
      name           = "general"
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
  }

  # ECR Repositories
  ecr_repositories = {
    app = {
      name = "my-app"
      scan_on_push = true
      lifecycle_policy = {
        max_image_count = 30
        max_age_days    = 90
      }
    }
  }

  # Security Groups
  security_groups = {
    app = {
      name = "app"
      description = "Security group for application"
      ingress_rules = [
        {
          description = "HTTP from ALB"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
        }
      ]
    }
  }

  tags = {
    Project     = "my-app"
    Environment = "dev"
    Owner       = "devops-team"
  }
}
```

### Advanced Example

```hcl
module "advanced_infrastructure" {
  source = "./vpc"

  name        = "advanced-app"
  environment = "prod"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
    enable_vpn_gateway = true
    enable_flow_log = true
    flow_log_retention_in_days = 30
  }

  # Subnet Configuration
  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    elasticache_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
    redshift_subnets = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
  }

  # EKS Configuration
  eks_node_groups = {
    general = {
      name           = "general"
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      max_size       = 6
      min_size       = 2
    }
    spot = {
      name           = "spot"
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "SPOT"
      desired_size   = 2
      max_size       = 4
      min_size       = 1
    }
  }

  # Application Load Balancers
  application_load_balancers = {
    main = {
      name = "main"
      internal = false
      security_groups = ["alb"]
      target_group = {
        port = 80
        protocol = "HTTP"
        target_type = "ip"
        health_check = {
          enabled = true
          path = "/health"
        }
      }
      listeners = [
        {
          port = 80
          protocol = "HTTP"
          default_action = {
            type = "forward"
            target_group_arn = "main"
          }
        }
      ]
    }
  }

  # RDS Databases
  rds_instances = {
    postgres = {
      name = "postgres"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.r6g.large"
      allocated_storage = 100
      storage_encrypted = true
      db_name = "myapp"
      username = "postgres"
      password = "changeme123!"
      security_group_ids = ["database"]
      multi_az = true
    }
  }

  # ElastiCache
  elasticache_clusters = {
    redis = {
      name = "redis"
      engine = "redis"
      node_type = "cache.r6g.large"
      num_cache_nodes = 1
      security_group_ids = ["cache"]
    }
  }

  # Lambda Functions
  lambda_functions = {
    processor = {
      name = "processor"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 300
      memory_size = 1024
      subnet_ids = ["private"]
      security_group_ids = ["lambda"]
    }
  }

  # Enable advanced features
  enable_cluster_autoscaler = true
  enable_network_policies = true
  enable_velero_backup = true

  tags = {
    Project     = "advanced-app"
    Environment = "prod"
    Owner       = "platform-team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.0 |
| aws | ~> 6.2.0 |
| terragrunt | >= 0.84.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.2.0 |
| kubernetes | >= 2.24.0 |
| helm | >= 2.12.0 |

## Inputs

### General Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name prefix for all resources | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

### VPC Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_config | VPC configuration | `object` | n/a | yes |
| subnet_config | Subnet configuration | `object` | n/a | yes |
| public_subnet_tags | Additional tags for public subnets | `map(string)` | `{}` | no |
| private_subnet_tags | Additional tags for private subnets | `map(string)` | `{}` | no |

### EKS Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| eks_config | EKS cluster configuration | `object` | `{}` | no |
| eks_node_groups | EKS node groups configuration | `map(object)` | `{}` | no |
| eks_fargate_profiles | EKS Fargate profiles configuration | `map(object)` | `{}` | no |

### Application Load Balancer

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_load_balancers | Application Load Balancer configuration | `map(object)` | `{}` | no |

### Database Services

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| rds_instances | RDS database instances configuration | `map(object)` | `{}` | no |
| elasticache_clusters | ElastiCache clusters configuration | `map(object)` | `{}` | no |

### Serverless Computing

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| lambda_functions | Lambda functions with VPC configuration | `map(object)` | `{}` | no |

### Container Registry

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecr_repositories | ECR repositories configuration | `map(object)` | `{}` | no |

### Security

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| security_groups | Security groups configuration | `map(object)` | `{}` | no |

### Monitoring and Features

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_cloudwatch_container_insights | Enable CloudWatch Container Insights | `bool` | `true` | no |
| enable_aws_load_balancer_controller | Enable AWS Load Balancer Controller | `bool` | `true` | no |
| enable_metrics_server | Enable Metrics Server | `bool` | `true` | no |
| enable_cluster_autoscaler | Enable Cluster Autoscaler | `bool` | `false` | no |
| enable_network_policies | Enable network policies for EKS | `bool` | `false` | no |
| network_policy_provider | Network policy provider | `string` | `"calico"` | no |
| enable_velero_backup | Enable Velero backup solution | `bool` | `false` | no |
| velero_backup_config | Velero backup configuration | `object` | `{}` | no |

## Outputs

### VPC Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| vpc_arn | The ARN of the VPC |
| private_subnets | List of IDs of private subnets |
| public_subnets | List of IDs of public subnets |
| database_subnets | List of IDs of database subnets |
| elasticache_subnets | List of IDs of ElastiCache subnets |
| redshift_subnets | List of IDs of Redshift subnets |
| intra_subnets | List of IDs of intra subnets |

### Application Load Balancer Outputs

| Name | Description |
|------|-------------|
| application_load_balancer_ids | Map of Application Load Balancer IDs |
| application_load_balancer_arns | Map of Application Load Balancer ARNs |
| application_load_balancer_dns_names | Map of Application Load Balancer DNS names |
| application_load_balancer_target_group_arns | Map of Application Load Balancer target group ARNs |

### Database Outputs

| Name | Description |
|------|-------------|
| rds_instance_ids | Map of RDS instance IDs |
| rds_instance_endpoints | Map of RDS instance endpoints |
| rds_subnet_group_id | RDS subnet group ID |
| elasticache_cluster_ids | Map of ElastiCache cluster IDs |
| elasticache_cluster_addresses | Map of ElastiCache cluster addresses |
| elasticache_subnet_group_id | ElastiCache subnet group ID |

### Lambda Outputs

| Name | Description |
|------|-------------|
| lambda_function_names | Map of Lambda function names |
| lambda_function_arns | Map of Lambda function ARNs |
| lambda_function_invoke_arns | Map of Lambda function invoke ARNs |
| lambda_role_arns | Map of Lambda IAM role ARNs |

### EKS Outputs

| Name | Description |
|------|-------------|
| cluster_id | EKS cluster ID |
| cluster_endpoint | Endpoint for EKS control plane |
| cluster_arn | The Amazon Resource Name (ARN) of the cluster |
| eks_managed_node_groups | Map of EKS managed node groups |
| fargate_profiles | Map of EKS Fargate profiles |

### ECR Outputs

| Name | Description |
|------|-------------|
| ecr_repository_urls | Map of ECR repository URLs |
| ecr_repository_arns | Map of ECR repository ARNs |
| ecr_registry_id | Registry ID |

### Security Outputs

| Name | Description |
|------|-------------|
| custom_security_group_ids | Map of custom security group IDs |
| eks_cluster_security_group_id | Security group ID attached to the EKS cluster |
| eks_nodes_security_group_id | Security group ID attached to the EKS nodes |

## Examples

### Basic Example
See `examples/basic/` for a simple setup with EKS, ECR, and basic security groups.

### Advanced Example
See `examples/advanced/` for a production-ready setup with multiple node groups, RDS, ElastiCache, and advanced monitoring.

### Data Lake Example
See `examples/data-lake/` for a data lake architecture with Redshift, S3, and data processing workloads.

## Best Practices

### Security
- Use security groups to restrict traffic between resources
- Enable VPC Flow Logs for network monitoring
- Use private subnets for sensitive resources
- Implement network policies for EKS clusters
- Use AWS Secrets Manager for sensitive data

### Cost Optimization
- Use Spot instances for non-critical workloads
- Enable cluster autoscaler to scale based on demand
- Use single NAT Gateway for dev environments
- Implement proper ECR lifecycle policies
- Use appropriate instance types for workloads

### High Availability
- Deploy resources across multiple Availability Zones
- Use Multi-AZ RDS instances for production
- Implement proper backup and recovery strategies
- Use multiple node groups for EKS clusters

### Monitoring
- Enable CloudWatch Container Insights
- Use proper logging and monitoring
- Implement health checks for load balancers
- Monitor resource utilization and costs

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions, please open an issue in the GitHub repository.