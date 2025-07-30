# ==============================================================================
# VPC Module Test Configuration
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
# Test Infrastructure Module
# ==============================================================================

module "test_infrastructure" {
  source = "../"

  name        = "test-vpc"
  environment = "test"

  # VPC Configuration
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
    single_nat_gateway = true
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
    redshift_subnets = ["10.0.41.0/24", "10.0.42.0/24"]
    intra_subnets = ["10.0.31.0/24", "10.0.32.0/24"]
  }

  # EKS Configuration
  eks_node_groups = {
    test = {
      name           = "test"
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      desired_size   = 1
      max_size       = 2
      min_size       = 1
      disk_size      = 20
      disk_type      = "gp3"
      labels = {
        node-type = "test"
        environment = "test"
      }
    }
  }

  # ECR Repositories
  ecr_repositories = {
    test = {
      name = "test-app"
      image_tag_mutability = "MUTABLE"
      scan_on_push = true
      encryption_type = "AES256"
      lifecycle_policy = {
        max_image_count = 10
        max_age_days    = 30
      }
    }
  }

  # Security Groups
  security_groups = {
    test = {
      name = "test"
      description = "Security group for test resources"
      ingress_rules = [
        {
          description = "HTTP from VPC"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
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
    test = {
      name = "test"
      internal = false
      security_groups = ["test"]
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
            target_group_arn = "test"
          }
        }
      ]
    }
  }

  # RDS Database
  rds_instances = {
    test = {
      name = "test"
      engine = "postgres"
      engine_version = "14.10"
      instance_class = "db.t3.micro"
      allocated_storage = 20
      storage_type = "gp2"
      storage_encrypted = true
      db_name = "test"
      username = "postgres"
      password = "test123!"  # Use AWS Secrets Manager in production
      security_group_ids = ["test"]
      backup_retention_period = 1
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
    test = {
      name = "test"
      engine = "redis"
      node_type = "cache.t3.micro"
      num_cache_nodes = 1
      port = 6379
      security_group_ids = ["test"]
      preferred_availability_zones = ["us-west-2a"]
    }
  }

  # Lambda Functions
  lambda_functions = {
    test = {
      name = "test"
      filename = "test_lambda.zip"
      handler = "index.handler"
      runtime = "nodejs18.x"
      timeout = 30
      memory_size = 128
      subnet_ids = ["private"]
      security_group_ids = ["test"]
      environment_variables = {
        ENVIRONMENT = "test"
      }
    }
  }

  # Enable monitoring and features
  enable_cloudwatch_container_insights = true
  enable_aws_load_balancer_controller = true
  enable_metrics_server = true
  enable_cluster_autoscaler = false  # Disabled for testing
  enable_network_policies = false    # Disabled for testing
  enable_velero_backup = false       # Disabled for testing

  # Common tags
  tags = {
    Project     = "vpc-test"
    Environment = "test"
    Owner       = "test-team"
    CostCenter  = "testing"
  }
}

# ==============================================================================
# Test Lambda Function
# ==============================================================================

# Create a simple test Lambda function
data "archive_file" "test_lambda" {
  type        = "zip"
  output_path = "test_lambda.zip"
  source {
    content = <<EOF
exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'Hello from test Lambda function!',
            timestamp: new Date().toISOString()
        })
    };
};
EOF
    filename = "index.js"
  }
}

# ==============================================================================
# Test EC2 Instance
# ==============================================================================

# Test EC2 instance to validate VPC connectivity
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "test" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = module.test_infrastructure.public_subnets[0]

  vpc_security_group_ids = [module.test_infrastructure.custom_security_group_ids["test"]]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Test Instance Running in VPC</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "test-instance"
    Environment = "test"
  }
}

# ==============================================================================
# Test S3 Bucket
# ==============================================================================

resource "aws_s3_bucket" "test" {
  bucket = "test-vpc-module-${random_string.bucket_suffix.result}"

  tags = {
    Name = "test-bucket"
    Environment = "test"
  }
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "test" {
  bucket = aws_s3_bucket.test.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ==============================================================================
# Test VPC Endpoints
# ==============================================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = module.test_infrastructure.vpc_id
  service_name = "com.amazonaws.us-west-2.s3"
  
  tags = {
    Name = "test-s3-endpoint"
    Environment = "test"
  }
}

# ==============================================================================
# Outputs for Testing
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.test_infrastructure.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = module.test_infrastructure.vpc_cidr_block
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.test_infrastructure.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.test_infrastructure.public_subnets
}

output "database_subnets" {
  description = "Database subnet IDs"
  value       = module.test_infrastructure.database_subnets
}

output "elasticache_subnets" {
  description = "ElastiCache subnet IDs"
  value       = module.test_infrastructure.elasticache_subnets
}

output "redshift_subnets" {
  description = "Redshift subnet IDs"
  value       = module.test_infrastructure.redshift_subnets
}

output "intra_subnets" {
  description = "Intra subnet IDs"
  value       = module.test_infrastructure.intra_subnets
}

output "eks_cluster_id" {
  description = "EKS cluster ID"
  value       = module.test_infrastructure.cluster_id
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.test_infrastructure.cluster_endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.test_infrastructure.ecr_repository_urls["test"]
}

output "application_load_balancer_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = module.test_infrastructure.application_load_balancer_dns_names["test"]
}

output "rds_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.test_infrastructure.rds_instance_endpoints["test"]
}

output "elasticache_cluster_address" {
  description = "ElastiCache cluster address"
  value       = module.test_infrastructure.elasticache_cluster_addresses["test"]
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.test_infrastructure.lambda_function_names["test"]
}

output "security_group_ids" {
  description = "Security group IDs"
  value       = module.test_infrastructure.custom_security_group_ids
}

output "test_instance_id" {
  description = "Test EC2 instance ID"
  value       = aws_instance.test.id
}

output "test_instance_public_ip" {
  description = "Test EC2 instance public IP"
  value       = aws_instance.test.public_ip
}

output "test_s3_bucket_name" {
  description = "Test S3 bucket name"
  value       = aws_s3_bucket.test.bucket
}

output "test_vpc_endpoint_id" {
  description = "Test VPC endpoint ID"
  value       = aws_vpc_endpoint.s3.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.test_infrastructure.nat_gateway_ids
}

output "nat_public_ips" {
  description = "NAT Gateway public IPs"
  value       = module.test_infrastructure.nat_public_ips
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = module.test_infrastructure.igw_id
}

output "route_table_ids" {
  description = "Route table IDs"
  value = {
    private = module.test_infrastructure.private_route_table_ids
    public  = module.test_infrastructure.public_route_table_ids
  }
} 