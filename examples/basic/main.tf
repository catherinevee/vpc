# ==============================================================================
# Basic Container Infrastructure Example with Multiple AWS Resources
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
# Container Infrastructure Module
# ==============================================================================

module "container_infrastructure" {
  source = "../../"

  name        = "my-app"
  environment = "dev"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true  # Cost optimization for dev environment
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_flow_log = true
    flow_log_retention_in_days = 7
  }

  # Subnet Configuration
  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
    elasticache_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
    intra_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
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
      disk_size      = 20
      disk_type      = "gp3"
      labels = {
        node-type = "general"
        environment = "dev"
      }
    }
  }

  # ECR Repositories
  ecr_repositories = {
    app = {
      name = "my-app"
      image_tag_mutability = "MUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 30
        max_age_days    = 90
      }
    }
    api = {
      name = "my-api"
      image_tag_mutability = "MUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 20
        max_age_days    = 60
      }
    }
  }

  # Security Groups
  security_groups = {
    app = {
      name = "app"
      description = "Security group for application pods"
      ingress_rules = [
        {
          description = "HTTP from ALB"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
        },
        {
          description = "HTTPS from ALB"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
        }
      ]
    }
    database = {
      name = "database"
      description = "Security group for RDS database"
      ingress_rules = [
        {
          description = "PostgreSQL from app"
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          security_groups = ["app"]
        }
      ]
    }
    cache = {
      name = "cache"
      description = "Security group for ElastiCache"
      ingress_rules = [
        {
          description = "Redis from app"
          from_port   = 6379
          to_port     = 6379
          protocol    = "tcp"
          security_groups = ["app"]
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
  }

  # Application Load Balancer
  application_load_balancers = {
    main = {
      name = "main"
      internal = false
      security_groups = ["app"]
      enable_deletion_protection = false
      enable_http2 = true
      target_group = {
        port = 80
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

  # RDS Database
  rds_instances = {
    postgres = {
      name = "postgres"
      engine = "postgres"
      engine_version = "14.10"
      instance_class = "db.t3.micro"
      allocated_storage = 20
      storage_type = "gp2"
      storage_encrypted = true
      db_name = "myapp"
      username = "postgres"
      password = "changeme123!"  # In production, use AWS Secrets Manager
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

  # ElastiCache
  elasticache_clusters = {
    redis = {
      name = "redis"
      engine = "redis"
      node_type = "cache.t3.micro"
      num_cache_nodes = 1
      port = 6379
      security_group_ids = ["cache"]
      preferred_availability_zones = ["us-west-2a"]
    }
  }

  # Lambda Functions with VPC
  lambda_functions = {
    processor = {
      name = "processor"
      filename = "lambda_function.zip"  # You would create this file
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 30
      memory_size = 256
      subnet_ids = ["private"]  # Will be resolved to actual subnet IDs
      security_group_ids = ["lambda"]
      environment_variables = {
        DATABASE_URL = "postgresql://postgres:changeme123!@${rds_endpoint}:5432/myapp"
        REDIS_URL = "redis://${redis_endpoint}:6379"
      }
    }
  }

  # Enable basic monitoring and features
  enable_cloudwatch_container_insights = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server = true

  # Common tags
  tags = {
    Project     = "my-app"
    Environment = "dev"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}

# ==============================================================================
# Outputs
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.container_infrastructure.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.container_infrastructure.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.container_infrastructure.public_subnets
}

output "database_subnets" {
  description = "Database subnet IDs"
  value       = module.container_infrastructure.database_subnets
}

output "elasticache_subnets" {
  description = "ElastiCache subnet IDs"
  value       = module.container_infrastructure.elasticache_subnets
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.container_infrastructure.cluster_endpoint
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.container_infrastructure.ecr_repository_urls
}

output "application_load_balancer_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.container_infrastructure.application_load_balancer_dns_names["main"]
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.container_infrastructure.rds_instance_endpoints["postgres"]
}

output "elasticache_cluster_address" {
  description = "ElastiCache cluster address"
  value       = module.container_infrastructure.elasticache_cluster_addresses["redis"]
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.container_infrastructure.lambda_function_names["processor"]
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.container_infrastructure.custom_security_group_ids
} 