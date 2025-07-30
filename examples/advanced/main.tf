# ==============================================================================
# Advanced Multi-Tier Infrastructure Example
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# ==============================================================================
# Advanced Container Infrastructure Module
# ==============================================================================

module "advanced_infrastructure" {
  source = "../../"

  name        = "advanced-app"
  environment = "prod"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = false  # High availability for production
    one_nat_gateway_per_az = true
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway = true
    enable_flow_log = true
    flow_log_retention_in_days = 30
  }

  # Subnet Configuration - Multi-tier architecture
  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    elasticache_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
    redshift_subnets = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
    intra_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  }

  # Additional subnet tags for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/advanced-app-eks-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/advanced-app-eks-cluster" = "shared"
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
      disk_size      = 50
      disk_type      = "gp3"
      labels = {
        node-type = "general"
        environment = "prod"
      }
    }
    spot = {
      name           = "spot"
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "SPOT"
      desired_size   = 2
      max_size       = 4
      min_size       = 1
      disk_size      = 50
      disk_type      = "gp3"
      labels = {
        node-type = "spot"
        environment = "prod"
      }
      taints = [
        {
          key    = "spot"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # EKS Fargate Profiles
  eks_fargate_profiles = {
    monitoring = {
      name = "monitoring"
      selectors = [
        {
          namespace = "monitoring"
          labels = {
            app = "monitoring"
          }
        }
      ]
    }
    batch = {
      name = "batch"
      selectors = [
        {
          namespace = "batch"
          labels = {
            app = "batch"
          }
        }
      ]
    }
  }

  # ECR Repositories
  ecr_repositories = {
    frontend = {
      name = "frontend"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 50
        max_age_days    = 90
      }
    }
    backend = {
      name = "backend"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 50
        max_age_days    = 90
      }
    }
    worker = {
      name = "worker"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 30
        max_age_days    = 60
      }
    }
  }

  # Security Groups - Comprehensive security model
  security_groups = {
    alb = {
      name = "alb"
      description = "Security group for Application Load Balancer"
      ingress_rules = [
        {
          description = "HTTP from internet"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTPS from internet"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    frontend = {
      name = "frontend"
      description = "Security group for frontend pods"
      ingress_rules = [
        {
          description = "HTTP from ALB"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          security_groups = ["alb"]
        },
        {
          description = "HTTPS from ALB"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          security_groups = ["alb"]
        }
      ]
    }
    backend = {
      name = "backend"
      description = "Security group for backend pods"
      ingress_rules = [
        {
          description = "HTTP from frontend"
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          security_groups = ["frontend"]
        }
      ]
    }
    database = {
      name = "database"
      description = "Security group for RDS database"
      ingress_rules = [
        {
          description = "PostgreSQL from backend"
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          security_groups = ["backend"]
        }
      ]
    }
    cache = {
      name = "cache"
      description = "Security group for ElastiCache"
      ingress_rules = [
        {
          description = "Redis from backend"
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          security_groups = ["backend"]
        }
      ]
    }
    lambda = {
      name = "lambda"
      description = "Security group for Lambda functions"
      egress_rules = [
        {
          description = "All outbound"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
    monitoring = {
      name = "monitoring"
      description = "Security group for monitoring services"
      ingress_rules = [
        {
          description = "Prometheus from monitoring"
          from_port   = 9090
          to_port     = 9090
          protocol    = "tcp"
          security_groups = ["monitoring"]
        }
      ]
    }
  }

  # Application Load Balancers
  application_load_balancers = {
    main = {
      name = "main"
      internal = false
      security_groups = ["alb"]
      enable_deletion_protection = true
      enable_http2 = true
      access_logs_bucket = "advanced-app-alb-logs"
      access_logs_prefix = "alb-logs"
      target_group = {
        port = 80
        protocol = "HTTP"
        target_type = "ip"
        health_check = {
          enabled = true
          healthy_threshold = 3
          interval = 30
          matcher = "200"
          path = "/health"
          port = "traffic-port"
          protocol = "HTTP"
          timeout = 10
          unhealthy_threshold = 3
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
        },
        {
          port = 443
          protocol = "HTTPS"
          ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
          certificate_arn = "arn:aws:acm:us-west-2:123456789012:certificate/example"
          default_action = {
            type = "forward"
            target_group_arn = "main"
          }
        }
      ]
    }
    internal = {
      name = "internal"
      internal = true
      security_groups = ["backend"]
      enable_deletion_protection = false
      enable_http2 = true
      target_group = {
        port = 8080
        protocol = "HTTP"
        target_type = "ip"
        health_check = {
          enabled = true
          healthy_threshold = 2
          interval = 30
          matcher = "200"
          path = "/health"
          port = "traffic-port"
          protocol = "HTTP"
          timeout = 5
          unhealthy_threshold = 2
        }
      }
      listeners = [
        {
          port = 8080
          protocol = "HTTP"
          default_action = {
            type = "forward"
            target_group_arn = "internal"
          }
        }
      ]
    }
  }

  # RDS Databases
  rds_instances = {
    postgres_primary = {
      name = "postgres-primary"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.r6g.large"
      allocated_storage = 100
      max_allocated_storage = 1000
      storage_type = "gp3"
      storage_encrypted = true
      db_name = "advancedapp"
      username = "postgres"
      password = "changeme123!"  # Use AWS Secrets Manager in production
      security_group_ids = ["database"]
      backup_retention_period = 30
      backup_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      multi_az = true
      publicly_accessible = false
      skip_final_snapshot = false
      deletion_protection = true
    }
    postgres_read_replica = {
      name = "postgres-read"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.r6g.large"
      allocated_storage = 100
      max_allocated_storage = 1000
      storage_type = "gp3"
      storage_encrypted = true
      db_name = "advancedapp"
      username = "postgres"
      password = "changeme123!"
      security_group_ids = ["database"]
      backup_retention_period = 7
      backup_window = "03:00-04:00"
      maintenance_window = "sun:04:00-sun:05:00"
      multi_az = false
      publicly_accessible = false
      skip_final_snapshot = true
      deletion_protection = false
    }
  }

  # ElastiCache Clusters
  elasticache_clusters = {
    redis_primary = {
      name = "redis-primary"
      engine = "redis"
      node_type = "cache.r6g.large"
      num_cache_nodes = 1
      port = 6379
      security_group_ids = ["cache"]
      preferred_availability_zones = ["us-west-2a"]
    }
    redis_replica = {
      name = "redis-replica"
      engine = "redis"
      node_type = "cache.r6g.large"
      num_cache_nodes = 1
      port = 6379
      security_group_ids = ["cache"]
      preferred_availability_zones = ["us-west-2b"]
    }
  }

  # Lambda Functions with VPC
  lambda_functions = {
    data_processor = {
      name = "data-processor"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 300
      memory_size = 1024
      subnet_ids = ["private"]
      security_group_ids = ["lambda"]
      environment_variables = {
        DATABASE_URL = "postgresql://postgres:changeme123!@${rds_endpoint}:5432/advancedapp"
        REDIS_URL = "redis://${redis_endpoint}:6379"
        ENVIRONMENT = "prod"
      }
    }
    image_processor = {
      name = "image-processor"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 900
      memory_size = 2048
      subnet_ids = ["private"]
      security_group_ids = ["lambda"]
      environment_variables = {
        DATABASE_URL = "postgresql://postgres:changeme123!@${rds_endpoint}:5432/advancedapp"
        ENVIRONMENT = "prod"
      }
    }
  }

  # Enable advanced monitoring and features
  enable_cloudwatch_container_insights = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server = true
  enable_cluster_autoscaler = true
  enable_network_policies = true
  network_policy_provider = "calico"
  enable_velero_backup = true

  velero_backup_config = {
    backup_location_bucket = "advanced-app-backups"
    backup_location_region = "us-west-2"
    schedule = "0 2 * * *"  # Daily at 2 AM
    retention_days = 30
  }

  # Common tags
  tags = {
    Project     = "advanced-app"
    Environment = "prod"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Compliance  = "sox"
    DataClassification = "confidential"
  }
}

# ==============================================================================
# Outputs
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.advanced_infrastructure.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.advanced_infrastructure.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.advanced_infrastructure.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.advanced_infrastructure.public_subnets
}

output "database_subnets" {
  description = "Database subnet IDs"
  value       = module.advanced_infrastructure.database_subnets
}

output "elasticache_subnets" {
  description = "ElastiCache subnet IDs"
  value       = module.advanced_infrastructure.elasticache_subnets
}

output "redshift_subnets" {
  description = "Redshift subnet IDs"
  value       = module.advanced_infrastructure.redshift_subnets
}

output "intra_subnets" {
  description = "Intra subnet IDs"
  value       = module.advanced_infrastructure.intra_subnets
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.advanced_infrastructure.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.advanced_infrastructure.cluster_endpoint
}

output "eks_node_groups" {
  description = "EKS node groups"
  value       = module.advanced_infrastructure.eks_managed_node_groups
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.advanced_infrastructure.ecr_repository_urls
}

output "application_load_balancer_dns_names" {
  description = "Application Load Balancer DNS names"
  value       = module.advanced_infrastructure.application_load_balancer_dns_names
}

output "rds_instance_endpoints" {
  description = "RDS instance endpoints"
  value       = module.advanced_infrastructure.rds_instance_endpoints
}

output "elasticache_cluster_addresses" {
  description = "ElastiCache cluster addresses"
  value       = module.advanced_infrastructure.elasticache_cluster_addresses
}

output "lambda_function_names" {
  description = "Lambda function names"
  value       = module.advanced_infrastructure.lambda_function_names
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.advanced_infrastructure.custom_security_group_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.advanced_infrastructure.nat_gateway_ids
}

output "nat_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.advanced_infrastructure.nat_public_ips
}

output "cluster_autoscaler_status" {
  description = "Cluster Autoscaler status"
  value       = module.advanced_infrastructure.cluster_autoscaler_status
}

output "velero_status" {
  description = "Velero backup status"
  value       = module.advanced_infrastructure.velero_status
} 