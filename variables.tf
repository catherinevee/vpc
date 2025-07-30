# ==============================================================================
# General Variables
# ==============================================================================

variable "name" {
  description = "Name prefix for all resources"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# VPC Variables
# ==============================================================================

variable "vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    enable_nat_gateway   = optional(bool, true)
    single_nat_gateway   = optional(bool, false)
    one_nat_gateway_per_az = optional(bool, false)
    enable_vpn_gateway   = optional(bool, false)
    enable_flow_log      = optional(bool, false)
    flow_log_retention_in_days = optional(number, 7)
  })
  validation {
    condition     = can(cidrhost(var.vpc_config.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = object({
    public_subnets  = list(string)
    private_subnets = list(string)
    database_subnets = optional(list(string), [])
    elasticache_subnets = optional(list(string), [])
    redshift_subnets = optional(list(string), [])
    intra_subnets = optional(list(string), [])
    azs             = list(string)
  })
  validation {
    condition = alltrue([
      for subnet in var.subnet_config.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDRs."
  }
  validation {
    condition = alltrue([
      for subnet in var.subnet_config.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid IPv4 CIDRs."
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Application Load Balancer Variables
# ==============================================================================

variable "application_load_balancers" {
  description = "Application Load Balancer configuration"
  type = map(object({
    name = string
    internal = optional(bool, false)
    security_groups = list(string)
    enable_deletion_protection = optional(bool, false)
    enable_http2 = optional(bool, true)
    access_logs_bucket = optional(string, null)
    access_logs_prefix = optional(string, "")
    target_group = object({
      port = number
      protocol = string
      target_type = string
      health_check = object({
        enabled = optional(bool, true)
        healthy_threshold = optional(number, 2)
        interval = optional(number, 30)
        matcher = optional(string, "200")
        path = optional(string, "/")
        port = optional(string, "traffic-port")
        protocol = optional(string, "HTTP")
        timeout = optional(number, 5)
        unhealthy_threshold = optional(number, 2)
      })
    })
    listeners = list(object({
      port = number
      protocol = string
      ssl_policy = optional(string, null)
      certificate_arn = optional(string, null)
      default_action = object({
        type = string
        target_group_arn = string
      })
      tags = optional(map(string), {})
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# RDS Variables
# ==============================================================================

variable "rds_instances" {
  description = "RDS database instances configuration"
  type = map(object({
    name = string
    engine = string
    engine_version = optional(string, null)
    instance_class = string
    allocated_storage = optional(number, 20)
    max_allocated_storage = optional(number, null)
    storage_type = optional(string, "gp2")
    storage_encrypted = optional(bool, true)
    db_name = string
    username = string
    password = string
    security_group_ids = list(string)
    backup_retention_period = optional(number, 7)
    backup_window = optional(string, "03:00-04:00")
    maintenance_window = optional(string, "sun:04:00-sun:05:00")
    multi_az = optional(bool, false)
    publicly_accessible = optional(bool, false)
    skip_final_snapshot = optional(bool, false)
    deletion_protection = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# ElastiCache Variables
# ==============================================================================

variable "elasticache_clusters" {
  description = "ElastiCache clusters configuration"
  type = map(object({
    name = string
    engine = string
    node_type = string
    num_cache_nodes = optional(number, 1)
    parameter_group_name = optional(string, null)
    port = optional(number, 6379)
    security_group_ids = list(string)
    preferred_availability_zones = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Lambda Variables
# ==============================================================================

variable "lambda_functions" {
  description = "Lambda functions with VPC configuration"
  type = map(object({
    name = string
    filename = string
    handler = string
    runtime = string
    timeout = optional(number, 3)
    memory_size = optional(number, 128)
    subnet_ids = list(string)
    security_group_ids = list(string)
    environment_variables = optional(map(string), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# EKS Variables
# ==============================================================================

variable "eks_config" {
  description = "EKS cluster configuration"
  type = object({
    cluster_version = optional(string, "1.28")
    cluster_endpoint_private_access = optional(bool, true)
    cluster_endpoint_public_access  = optional(bool, true)
    cluster_endpoint_public_access_cidrs = optional(list(string), ["0.0.0.0/0"])
    cluster_service_ipv4_cidr = optional(string, "172.16.0.0/12")
    cluster_ip_family = optional(string, "ipv4")
    enable_irsa = optional(bool, true)
    enable_cluster_creator_admin_permissions = optional(bool, true)
    create_cloudwatch_log_group = optional(bool, true)
    cluster_log_retention_in_days = optional(number, 7)
    cluster_log_types = optional(list(string), ["api", "audit", "authenticator", "controllerManager", "scheduler"])
  })
  default = {}
}

variable "eks_node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    name = string
    instance_types = list(string)
    capacity_type = optional(string, "ON_DEMAND")
    disk_size = optional(number, 20)
    disk_type = optional(string, "gp3")
    ami_type = optional(string, "AL2_x86_64")
    platform = optional(string, "linux")
    desired_size = optional(number, 2)
    max_size = optional(number, 5)
    min_size = optional(number, 1)
    max_unavailable = optional(number, 1)
    max_unavailable_percentage = optional(number, null)
    force_update_version = optional(bool, false)
    update_config = optional(object({
      max_unavailable_percentage = optional(number, 33)
    }), {})
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "eks_fargate_profiles" {
  description = "EKS Fargate profiles configuration"
  type = map(object({
    name = string
    selectors = list(object({
      namespace = string
      labels = optional(map(string), {})
    }))
    subnets = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# ECR Variables
# ==============================================================================

variable "ecr_repositories" {
  description = "ECR repositories configuration"
  type = map(object({
    name = string
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push = optional(bool, true)
    encryption_type = optional(string, "AES256")
    kms_key_id = optional(string, null)
    lifecycle_policy = optional(object({
      max_image_count = optional(number, 30)
      max_age_days = optional(number, 90)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Security Groups Variables
# ==============================================================================

variable "security_groups" {
  description = "Security groups configuration"
  type = map(object({
    name = string
    description = string
    vpc_id = optional(string, null)
    ingress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), [])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
    })), [])
    egress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Monitoring and Logging Variables
# ==============================================================================

variable "enable_cloudwatch_container_insights" {
  description = "Enable CloudWatch Container Insights for EKS"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable Metrics Server"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler"
  type        = bool
  default     = false
}

# ==============================================================================
# Backup and Disaster Recovery Variables
# ==============================================================================

variable "enable_velero_backup" {
  description = "Enable Velero backup solution"
  type        = bool
  default     = false
}

variable "velero_backup_config" {
  description = "Velero backup configuration"
  type = object({
    backup_location_bucket = optional(string, "")
    backup_location_region = optional(string, "")
    schedule = optional(string, "0 2 * * *") # Daily at 2 AM
    retention_days = optional(number, 30)
  })
  default = {}
}

# ==============================================================================
# Network Policy Variables
# ==============================================================================

variable "enable_network_policies" {
  description = "Enable network policies for EKS"
  type        = bool
  default     = false
}

variable "network_policy_provider" {
  description = "Network policy provider (calico, cilium, or aws-vpc-cni)"
  type        = string
  default     = "calico"
  validation {
    condition     = contains(["calico", "cilium", "aws-vpc-cni"], var.network_policy_provider)
    error_message = "Network policy provider must be one of: calico, cilium, aws-vpc-cni."
  }
} 