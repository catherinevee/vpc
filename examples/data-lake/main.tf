# ==============================================================================
# Data Lake Infrastructure Example
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
# Data Lake Infrastructure Module
# ==============================================================================

module "data_lake_infrastructure" {
  source = "../../"

  name        = "data-lake"
  environment = "prod"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = false
    one_nat_gateway_per_az = true
    enable_dns_hostnames = true
    enable_dns_support   = true
    enable_vpn_gateway = true
    enable_flow_log = true
    flow_log_retention_in_days = 90
  }

  # Subnet Configuration - Data Lake architecture
  subnet_config = {
    azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
    database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
    elasticache_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
    redshift_subnets = ["10.0.41.0/24", "10.0.42.0/24", "10.0.43.0/24"]
    intra_subnets = ["10.0.31.0/24", "10.0.32.0/24", "10.0.33.0/24"]
  }

  # EKS Configuration for data processing
  eks_node_groups = {
    data_processing = {
      name           = "data-processing"
      instance_types = ["m5.large", "m5.xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 3
      max_size       = 10
      min_size       = 2
      disk_size      = 100
      disk_type      = "gp3"
      labels = {
        node-type = "data-processing"
        environment = "prod"
        workload = "batch"
      }
    }
    ml_training = {
      name           = "ml-training"
      instance_types = ["g4dn.xlarge", "g4dn.2xlarge"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 1
      max_size       = 5
      min_size       = 0
      disk_size      = 200
      disk_type      = "gp3"
      labels = {
        node-type = "ml-training"
        environment = "prod"
        workload = "ml"
      }
      taints = [
        {
          key    = "nvidia.com/gpu"
          value  = "present"
          effect = "NO_SCHEDULE"
        }
      ]
    }
  }

  # EKS Fargate Profiles for serverless workloads
  eks_fargate_profiles = {
    data_ingestion = {
      name = "data-ingestion"
      selectors = [
        {
          namespace = "data-ingestion"
          labels = {
            app = "data-ingestion"
          }
        }
      ]
    }
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
  }

  # ECR Repositories for data processing containers
  ecr_repositories = {
    data_processor = {
      name = "data-processor"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 100
        max_age_days    = 180
      }
    }
    ml_training = {
      name = "ml-training"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 50
        max_age_days    = 365
      }
    }
    data_ingestion = {
      name = "data-ingestion"
      image_tag_mutability = "IMMUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 30
        max_age_days    = 90
      }
    }
  }

  # Security Groups for data lake components
  security_groups = {
    redshift = {
      name = "redshift"
      description = "Security group for Redshift cluster"
      ingress_rules = [
        {
          description = "Redshift from data processing"
          from_port   = 5439
          to_port     = 5439
          protocol    = "tcp"
          security_groups = ["data-processing"]
        }
      ]
    }
    data_processing = {
      name = "data-processing"
      description = "Security group for data processing pods"
      ingress_rules = [
        {
          description = "HTTP from internal ALB"
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          security_groups = ["internal-alb"]
        }
      ]
    }
    internal_alb = {
      name = "internal-alb"
      description = "Security group for internal Application Load Balancer"
      ingress_rules = [
        {
          description = "HTTP from VPC"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
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
        },
        {
          description = "Grafana from monitoring"
          from_port   = 3000
          to_port     = 3000
          protocol    = "tcp"
          security_groups = ["monitoring"]
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

  # Application Load Balancer for internal services
  application_load_balancers = {
    internal = {
      name = "internal"
      internal = true
      security_groups = ["internal-alb"]
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
          timeout = 10
          unhealthy_threshold = 3
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

  # RDS Database for metadata
  rds_instances = {
    metadata = {
      name = "metadata"
      engine = "postgres"
      engine_version = "15.4"
      instance_class = "db.r6g.large"
      allocated_storage = 200
      max_allocated_storage = 2000
      storage_type = "gp3"
      storage_encrypted = true
      db_name = "datalake_metadata"
      username = "postgres"
      password = "changeme123!"  # Use AWS Secrets Manager in production
      security_group_ids = ["redshift"]
      backup_retention_period = 30
      backup_window = "02:00-03:00"
      maintenance_window = "sun:03:00-sun:04:00"
      multi_az = true
      publicly_accessible = false
      skip_final_snapshot = false
      deletion_protection = true
    }
  }

  # ElastiCache for caching
  elasticache_clusters = {
    redis_cache = {
      name = "redis-cache"
      engine = "redis"
      node_type = "cache.r6g.large"
      num_cache_nodes = 1
      port = 6379
      security_group_ids = ["data-processing"]
      preferred_availability_zones = ["us-west-2a"]
    }
  }

  # Lambda Functions for data processing
  lambda_functions = {
    data_transformer = {
      name = "data-transformer"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "python3.11"
      timeout = 900
      memory_size = 2048
      subnet_ids = ["private"]
      security_group_ids = ["lambda"]
      environment_variables = {
        REDSHIFT_ENDPOINT = "${redshift_endpoint}"
        S3_BUCKET = "data-lake-raw-data"
        ENVIRONMENT = "prod"
      }
    }
    data_validator = {
      name = "data-validator"
      filename = "lambda_function.zip"
      handler = "index.handler"
      runtime = "python3.11"
      timeout = 300
      memory_size = 1024
      subnet_ids = ["private"]
      security_group_ids = ["lambda"]
      environment_variables = {
        S3_BUCKET = "data-lake-raw-data"
        ENVIRONMENT = "prod"
      }
    }
  }

  # Enable monitoring and features
  enable_cloudwatch_container_insights = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server = true
  enable_cluster_autoscaler = true
  enable_network_policies = true
  network_policy_provider = "calico"
  enable_velero_backup = true

  velero_backup_config = {
    backup_location_bucket = "data-lake-backups"
    backup_location_region = "us-west-2"
    schedule = "0 1 * * *"  # Daily at 1 AM
    retention_days = 90
  }

  # Common tags
  tags = {
    Project     = "data-lake"
    Environment = "prod"
    Owner       = "data-engineering"
    CostCenter  = "analytics"
    DataClassification = "confidential"
    Compliance  = "gdpr"
  }
}

# ==============================================================================
# Additional Data Lake Resources
# ==============================================================================

# S3 Buckets for data lake
resource "aws_s3_bucket" "data_lake" {
  for_each = toset([
    "data-lake-raw-data",
    "data-lake-processed-data",
    "data-lake-curated-data",
    "data-lake-logs",
    "data-lake-backups"
  ])

  bucket = "${each.value}-${random_string.bucket_suffix.result}"

  tags = {
    Name = each.value
    Environment = "prod"
    Project = "data-lake"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id

  rule {
    id     = "data_lifecycle"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = 2555  # 7 years
    }
  }
}

# Redshift Cluster
resource "aws_redshift_cluster" "data_lake" {
  cluster_identifier        = "data-lake-cluster"
  database_name            = "datalake"
  master_username          = "admin"
  master_password          = "changeme123!"  # Use AWS Secrets Manager in production
  node_type                = "dc2.large"
  cluster_type             = "single-node"
  skip_final_snapshot      = false
  final_snapshot_identifier = "data-lake-final-snapshot"

  vpc_security_group_ids = [module.data_lake_infrastructure.custom_security_group_ids["redshift"]]
  cluster_subnet_group_name = aws_redshift_subnet_group.data_lake.name

  tags = {
    Name = "data-lake-redshift"
    Environment = "prod"
    Project = "data-lake"
  }
}

resource "aws_redshift_subnet_group" "data_lake" {
  name       = "data-lake-redshift-subnet-group"
  subnet_ids = module.data_lake_infrastructure.redshift_subnets

  tags = {
    Name = "data-lake-redshift-subnet-group"
    Environment = "prod"
    Project = "data-lake"
  }
}

# ==============================================================================
# Outputs
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.data_lake_infrastructure.vpc_id
}

output "redshift_subnets" {
  description = "Redshift subnet IDs"
  value       = module.data_lake_infrastructure.redshift_subnets
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.data_lake_infrastructure.cluster_id
}

output "redshift_cluster_endpoint" {
  description = "Redshift cluster endpoint"
  value       = aws_redshift_cluster.data_lake.endpoint
}

output "redshift_cluster_identifier" {
  description = "Redshift cluster identifier"
  value       = aws_redshift_cluster.data_lake.cluster_identifier
}

output "s3_bucket_names" {
  description = "S3 bucket names"
  value       = { for k, v in aws_s3_bucket.data_lake : k => v.bucket }
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = module.data_lake_infrastructure.ecr_repository_urls
}

output "lambda_function_names" {
  description = "Lambda function names"
  value       = module.data_lake_infrastructure.lambda_function_names
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.data_lake_infrastructure.rds_instance_endpoints["metadata"]
}

output "elasticache_cluster_address" {
  description = "ElastiCache cluster address"
  value       = module.data_lake_infrastructure.elasticache_cluster_addresses["redis_cache"]
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.data_lake_infrastructure.custom_security_group_ids
} 