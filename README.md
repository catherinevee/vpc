# AWS VPC Infrastructure Module

Terraform module for AWS VPC infrastructure with EKS, RDS, ElastiCache, ALB, Lambda, and ECR integration.

## What This Module Does

- Creates multi-tier VPC with public, private, database, cache, and analytics subnets
- Deploys EKS clusters with managed node groups and Fargate profiles
- Sets up RDS instances with proper subnet groups and security
- Configures ElastiCache for Redis and Memcached workloads
- Provisions Application Load Balancers with health checks and routing
- Deploys Lambda functions with VPC connectivity
- Creates ECR repositories with image lifecycle management
- Implements security groups with least-privilege access
- Enables CloudWatch monitoring and log aggregation
- Supports Velero backup for Kubernetes disaster recovery
- Integrates Calico or Cilium for network policies

## Resource Map

| Resource | Purpose | Notes |
|----------|---------|-------|
| VPC | Network isolation | Main virtual network for all resources |
| Public Subnets | Internet-facing resources | Load balancers, NAT gateways |
| Private Subnets | Application workloads | EKS nodes, Lambda functions |
| Database Subnets | Data persistence | RDS instances, isolated from app layer |
| Cache Subnets | Session/data caching | ElastiCache clusters |
| Analytics Subnets | Data warehousing | Redshift clusters (optional) |
| NAT Gateways | Outbound internet access | For private subnet resources |
| Internet Gateway | Inbound internet access | For public subnet resources |
| Security Groups | Network access control | Least-privilege firewall rules |
| EKS Cluster | Container orchestration | Managed Kubernetes control plane |
| EKS Node Groups | Worker nodes | EC2 instances for pod execution |
| ALB | Load distribution | Layer 7 routing with health checks |
| RDS | Managed databases | PostgreSQL, MySQL with Multi-AZ |
| ElastiCache | In-memory caching | Redis/Memcached for performance |
| Lambda | Event-driven compute | Serverless functions with VPC access |
| ECR | Container images | Private Docker registry with scanning |
| CloudWatch | Observability | Metrics, logs, and alerting |
| IAM Roles | Access management | Service-to-service authentication |

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

### Basic Setup

```hcl
module "vpc_infrastructure" {
  source = "./vpc"

  name        = "my-app"
  environment = "dev"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true  # Cost optimization for dev
  }

  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  }

  # Basic EKS setup
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

  # Container registry for application images
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

  tags = {
    Project     = "my-app"
    Environment = "dev"
    Owner       = "devops-team"
  }
}
```

### Production Setup

```hcl
module "production_infrastructure" {
  source = "./vpc"

  name        = "production-app"
  environment = "prod"

  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    one_nat_gateway_per_az = true  # High availability
    enable_flow_log = true
    flow_log_retention_in_days = 30
  }

  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    elasticache_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
  }

  # Mixed capacity for cost optimization
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

  # Database with Multi-AZ for disaster recovery
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
      multi_az = true  # Production requirement
    }
  }

  # Redis for session management
  elasticache_clusters = {
    redis = {
      name = "redis"
      engine = "redis"
      node_type = "cache.r6g.large"
      num_cache_nodes = 1
    }
  }

  enable_cluster_autoscaler = true
  enable_velero_backup = true

  tags = {
    Project     = "production-app"
    Environment = "prod"
    Owner       = "platform-team"
  }
}
```

## Key Configuration Notes

### NAT Gateway Costs
- Use `single_nat_gateway = true` for dev environments to reduce costs
- Set `one_nat_gateway_per_az = true` for production high availability
- Each NAT Gateway costs ~$45/month plus data processing fees

### EKS Node Sizing
- t3.medium sufficient for development workloads
- t3.large or larger recommended for production
- Mix ON_DEMAND and SPOT instances to balance cost and reliability
- Enable cluster autoscaler in production to handle traffic spikes

### Database Multi-AZ
- Always enable `multi_az = true` in production
- Adds ~100% to RDS costs but provides automatic failover
- Use appropriate instance classes: db.t3.micro for dev, db.r6g.large+ for prod

### Security Groups
- The module creates baseline EKS security groups automatically
- Add custom security groups for application-specific access patterns
- Default rules allow all outbound traffic - restrict as needed

### ECR Lifecycle Policies
- Prevents repository storage costs from growing unchecked
- `max_image_count = 30` keeps recent images for rollbacks
- `max_age_days = 90` removes old images automatically

## Requirements

| Tool | Version | Notes |
|------|---------|-------|
| terraform | >= 1.13.0 | Module uses optional object attributes |
| aws | ~> 6.2.0 | Latest provider with EKS improvements |
| terragrunt | >= 0.84.0 | For environment-specific deployments |
| kubernetes | >= 2.24.0 | Required for EKS post-deployment configuration |
| helm | >= 2.12.0 | Installs cluster addons and monitoring |

## Core Variables

| Variable | Purpose | Type | Notes |
|----------|---------|------|-------|
| name | Resource naming prefix | `string` | Used for all resource names |
| environment | Deployment environment | `string` | Typically dev/staging/prod |
| tags | Resource tagging | `map(string)` | Applied to all resources |

### VPC Configuration

| Variable | Purpose | Important Settings |
|----------|---------|-------------------|
| vpc_config | Network setup | `cidr_block` (required), `enable_nat_gateway`, `single_nat_gateway` |
| subnet_config | Subnet allocation | `azs` (required), `private_subnets`, `public_subnets`, `database_subnets` |

### EKS Configuration

| Variable | Purpose | Key Options |
|----------|---------|-------------|
| eks_config | Cluster settings | `cluster_version`, endpoint access controls |
| eks_node_groups | Worker nodes | Instance types, scaling, capacity type (ON_DEMAND/SPOT) |
| eks_fargate_profiles | Serverless pods | Namespace selectors, subnet placement |

### Data Services

| Variable | Purpose | Production Considerations |
|----------|---------|-------------------------|
| rds_instances | Managed databases | Enable `multi_az`, set `backup_retention_period` |
| elasticache_clusters | In-memory caching | Choose appropriate node types, enable encryption |

### Container & Load Balancing

| Variable | Purpose | Common Use Cases |
|----------|---------|------------------|
| application_load_balancers | HTTP(S) routing | SSL termination, health checks |
| ecr_repositories | Container images | Enable vulnerability scanning |
| lambda_functions | Event processing | VPC-connected functions for data access |

### Security & Monitoring

| Variable | Purpose | Default | Production Recommendation |
|----------|---------|---------|---------------------------|
| security_groups | Network access | `{}` | Define application-specific rules |
| enable_cluster_autoscaler | Auto-scaling | `false` | Enable for production workloads |
| enable_network_policies | Pod-to-pod security | `false` | Consider for multi-tenant clusters |
| enable_velero_backup | Disaster recovery | `false` | Essential for production |

## Module Outputs

### Network Information
- VPC ID, CIDR blocks, and subnet IDs for integration with other modules
- NAT Gateway and Internet Gateway IDs for routing configuration
- Route table IDs for custom routing rules

### Application Infrastructure
- ALB DNS names and ARNs for DNS configuration and service integration
- Target group ARNs for container service registration
- Security group IDs for additional rule configuration

### Data Layer
- RDS endpoints and port information for application configuration
- ElastiCache cluster addresses for session store and caching setup
- Subnet group IDs for additional database deployments

### Container Platform
- EKS cluster endpoint and certificate data for kubectl configuration
- ECR repository URLs for container build pipelines
- Node group details for monitoring and troubleshooting

### Security Context
- IAM role ARNs for service account integration and cross-service access
- Security group IDs for application-specific rule additions
- KMS key information when encryption is enabled

## Implementation Guide

### Basic Deployment
1. Set up the module with minimal required variables
2. Deploy VPC and networking components first
3. Add EKS cluster and node groups
4. Configure ECR repositories for container storage
5. Deploy applications and verify connectivity

### Adding Databases
```hcl
rds_instances = {
  main = {
    name = "main-db"
    engine = "postgres"
    instance_class = "db.t3.micro"  # Start small, scale up
    allocated_storage = 20
    db_name = var.database_name
    username = var.database_username
    multi_az = var.environment == "prod"
  }
}
```

### Production Checklist
- [ ] Multi-AZ NAT Gateways for high availability
- [ ] RDS Multi-AZ enabled for database failover
- [ ] VPC Flow Logs enabled for security auditing
- [ ] Cluster autoscaler configured for demand scaling
- [ ] Velero backup configured with S3 backend
- [ ] Network policies implemented for pod isolation
- [ ] Resource tagging strategy implemented
- [ ] IAM roles follow least privilege principle

## Cost Considerations

### Major Cost Drivers
1. **NAT Gateways**: $45/month each plus data processing
2. **EKS Control Plane**: $0.10/hour ($73/month)
3. **RDS Multi-AZ**: ~2x single instance cost
4. **ALB**: $22/month plus LCU charges
5. **Data Transfer**: Inter-AZ and internet egress charges

### Cost Optimization
- Use single NAT Gateway in dev environments
- Leverage Spot instances for non-critical workloads
- Implement ECR lifecycle policies to control storage costs
- Use appropriate RDS instance types (t3.micro for dev)
- Enable cluster autoscaler to avoid over-provisioning

## Troubleshooting

### Common Issues
- **Pods stuck in pending**: Check node group scaling limits and resource requests
- **Database connection timeouts**: Verify security group rules and subnet routing
- **Load balancer health check failures**: Confirm target group health check configuration
- **ECR authentication failures**: Ensure proper IAM roles for EKS node groups

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