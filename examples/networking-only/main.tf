# ==============================================================================
# Networking Only Infrastructure Example
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
# Networking Infrastructure Module
# ==============================================================================

module "networking_infrastructure" {
  source = "../../"

  name        = "networking-demo"
  environment = "dev"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true  # Cost optimization for dev
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

  # Security Groups
  security_groups = {
    web = {
      name = "web"
      description = "Security group for web servers"
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
        },
        {
          description = "SSH from office"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["192.168.1.0/24"]  # Office IP range
        }
      ]
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
    app = {
      name = "app"
      description = "Security group for application servers"
      ingress_rules = [
        {
          description = "HTTP from web servers"
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          security_groups = ["web"]
        },
        {
          description = "SSH from office"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["192.168.1.0/24"]
        }
      ]
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
    database = {
      name = "database"
      description = "Security group for database servers"
      ingress_rules = [
        {
          description = "PostgreSQL from app servers"
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          security_groups = ["app"]
        },
        {
          description = "SSH from office"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["192.168.1.0/24"]
        }
      ]
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
    web = {
      name = "web"
      internal = false
      security_groups = ["web"]
      enable_deletion_protection = false
      enable_http2 = true
      target_group = {
        port = 80
        protocol = "HTTP"
        target_type = "instance"
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
            target_group_arn = "web"
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
      db_name = "demo"
      username = "postgres"
      password = "changeme123!"  # Use AWS Secrets Manager in production
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
      security_group_ids = ["app"]
      preferred_availability_zones = ["us-west-2a"]
    }
  }

  # Lambda Functions
  lambda_functions = {
    api = {
      name = "api"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 30
      memory_size = 128
      subnet_ids = ["private"]
      security_group_ids = ["app"]
      environment_variables = {
        DATABASE_URL = "postgresql://postgres:changeme123!@${rds_endpoint}:5432/demo"
        REDIS_URL = "redis://${redis_endpoint}:6379"
        ENVIRONMENT = "dev"
      }
    }
  }

  # Common tags
  tags = {
    Project     = "networking-demo"
    Environment = "dev"
    Owner       = "devops-team"
    CostCenter  = "engineering"
  }
}

# ==============================================================================
# Additional Networking Resources
# ==============================================================================

# VPC Endpoints for AWS Services
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.networking_infrastructure.vpc_id
  service_name = "com.amazonaws.us-west-2.s3"
  
  tags = {
    Name = "s3-endpoint"
    Environment = "dev"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = module.networking_infrastructure.vpc_id
  service_name = "com.amazonaws.us-west-2.dynamodb"
  
  tags = {
    Name = "dynamodb-endpoint"
    Environment = "dev"
  }
}

# Network ACLs
resource "aws_network_acl" "main" {
  vpc_id = module.networking_infrastructure.vpc_id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "main-nacl"
    Environment = "dev"
  }
}

# Associate NACL with subnets
resource "aws_network_acl_association" "public" {
  count = length(module.networking_infrastructure.public_subnets)
  
  network_acl_id = aws_network_acl.main.id
  subnet_id      = module.networking_infrastructure.public_subnets[count.index]
}

resource "aws_network_acl_association" "private" {
  count = length(module.networking_infrastructure.private_subnets)
  
  network_acl_id = aws_network_acl.main.id
  subnet_id      = module.networking_infrastructure.private_subnets[count.index]
}

# ==============================================================================
# Outputs
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking_infrastructure.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.networking_infrastructure.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.networking_infrastructure.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.networking_infrastructure.public_subnets
}

output "database_subnets" {
  description = "Database subnet IDs"
  value       = module.networking_infrastructure.database_subnets
}

output "elasticache_subnets" {
  description = "ElastiCache subnet IDs"
  value       = module.networking_infrastructure.elasticache_subnets
}

output "intra_subnets" {
  description = "Intra subnet IDs"
  value       = module.networking_infrastructure.intra_subnets
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.networking_infrastructure.nat_gateway_ids
}

output "nat_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.networking_infrastructure.nat_public_ips
}

output "application_load_balancer_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.networking_infrastructure.application_load_balancer_dns_names["web"]
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.networking_infrastructure.rds_instance_endpoints["postgres"]
}

output "elasticache_cluster_address" {
  description = "ElastiCache cluster address"
  value       = module.networking_infrastructure.elasticache_cluster_addresses["redis"]
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.networking_infrastructure.lambda_function_names["api"]
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.networking_infrastructure.custom_security_group_ids
}

output "vpc_endpoint_ids" {
  description = "VPC endpoint IDs"
  value = {
    s3       = aws_vpc_endpoint.s3.id
    dynamodb = aws_vpc_endpoint.dynamodb.id
  }
}

output "network_acl_id" {
  description = "Network ACL ID"
  value       = aws_network_acl.main.id
} 