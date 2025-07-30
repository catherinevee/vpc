# ==============================================================================
# Data Sources
# ==============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# ==============================================================================
# Local Values
# ==============================================================================

locals {
  common_tags = merge(var.tags, {
    Name        = var.name
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "container-infrastructure"
  })

  # VPC Configuration
  vpc_name = "${var.name}-vpc"
  
  # EKS Configuration
  cluster_name = "${var.name}-eks-cluster"
  
  # ECR Configuration
  ecr_repository_names = [for repo in var.ecr_repositories : repo.name]
}

# ==============================================================================
# VPC and Networking
# ==============================================================================

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = var.vpc_config.cidr_block

  azs             = var.subnet_config.azs
  private_subnets = var.subnet_config.private_subnets
  public_subnets  = var.subnet_config.public_subnets
  database_subnets = var.subnet_config.database_subnets
  elasticache_subnets = var.subnet_config.elasticache_subnets
  redshift_subnets = var.subnet_config.redshift_subnets
  intra_subnets = var.subnet_config.intra_subnets

  enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
  enable_dns_support   = var.vpc_config.enable_dns_support

  enable_nat_gateway     = var.vpc_config.enable_nat_gateway
  single_nat_gateway     = var.vpc_config.single_nat_gateway
  one_nat_gateway_per_az = var.vpc_config.one_nat_gateway_per_az

  enable_vpn_gateway = var.vpc_config.enable_vpn_gateway

  enable_flow_log                      = var.vpc_config.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.vpc_config.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.vpc_config.enable_flow_log
  flow_log_retention_in_days           = var.vpc_config.flow_log_retention_in_days

  # EKS specific subnet tags
  public_subnet_tags = merge({
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }, var.public_subnet_tags)

  private_subnet_tags = merge({
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }, var.private_subnet_tags)

  tags = local.common_tags
}

# ==============================================================================
# Security Groups
# ==============================================================================

resource "aws_security_group" "eks_cluster" {
  count = length(var.eks_node_groups) > 0 ? 1 : 0

  name_prefix = "${var.name}-eks-cluster-"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-eks-cluster-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "eks_nodes" {
  count = length(var.eks_node_groups) > 0 ? 1 : 0

  name_prefix = "${var.name}-eks-nodes-"
  description = "Security group for EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Node groups to cluster API"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster[0].id]
  }

  ingress {
    description     = "Node groups to cluster API"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster[0].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-eks-nodes-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Custom Security Groups
resource "aws_security_group" "custom" {
  for_each = var.security_groups

  name_prefix = "${var.name}-${each.value.name}-"
  description = each.value.description
  vpc_id      = each.value.vpc_id != null ? each.value.vpc_id : module.vpc.vpc_id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      self            = ingress.value.self
    }
  }

  dynamic "egress" {
    for_each = each.value.egress_rules
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.security_groups
      self            = egress.value.self
    }
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ==============================================================================
# Application Load Balancer
# ==============================================================================

resource "aws_lb" "application" {
  for_each = var.application_load_balancers

  name               = "${var.name}-${each.value.name}-alb"
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = each.value.security_groups
  subnets            = each.value.internal ? module.vpc.private_subnets : module.vpc.public_subnets

  enable_deletion_protection = each.value.enable_deletion_protection
  enable_http2               = each.value.enable_http2

  access_logs {
    bucket  = each.value.access_logs_bucket
    prefix  = each.value.access_logs_prefix
    enabled = each.value.access_logs_bucket != null
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-alb"
  })
}

resource "aws_lb_listener" "application" {
  for_each = {
    for listener in local.alb_listeners : "${listener.alb_key}-${listener.port}-${listener.protocol}" => listener
  }

  load_balancer_arn = aws_lb.application[each.value.alb_key].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn

  default_action {
    type             = each.value.default_action.type
    target_group_arn = each.value.default_action.target_group_arn
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.alb_key}-listener-${each.value.port}"
  })
}

resource "aws_lb_target_group" "application" {
  for_each = var.application_load_balancers

  name     = "${var.name}-${each.value.name}-tg"
  port     = each.value.target_group.port
  protocol = each.value.target_group.protocol
  vpc_id   = module.vpc.vpc_id

  target_type = each.value.target_group.target_type

  dynamic "health_check" {
    for_each = [each.value.target_group.health_check]
    content {
      enabled             = health_check.value.enabled
      healthy_threshold   = health_check.value.healthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      unhealthy_threshold = health_check.value.unhealthy_threshold
    }
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-tg"
  })
}

# ==============================================================================
# RDS Database
# ==============================================================================

resource "aws_db_subnet_group" "main" {
  count = length(var.rds_instances) > 0 ? 1 : 0

  name       = "${var.name}-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = merge(local.common_tags, {
    Name = "${var.name}-db-subnet-group"
  })
}

resource "aws_db_instance" "main" {
  for_each = var.rds_instances

  identifier = "${var.name}-${each.value.name}"

  engine         = each.value.engine
  engine_version = each.value.engine_version
  instance_class = each.value.instance_class

  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_type          = each.value.storage_type
  storage_encrypted     = each.value.storage_encrypted

  db_name  = each.value.db_name
  username = each.value.username
  password = each.value.password

  vpc_security_group_ids = each.value.security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.main[0].name

  backup_retention_period = each.value.backup_retention_period
  backup_window          = each.value.backup_window
  maintenance_window     = each.value.maintenance_window

  multi_az               = each.value.multi_az
  publicly_accessible    = each.value.publicly_accessible
  skip_final_snapshot    = each.value.skip_final_snapshot
  deletion_protection    = each.value.deletion_protection

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-db"
  })
}

# ==============================================================================
# ElastiCache
# ==============================================================================

resource "aws_elasticache_subnet_group" "main" {
  count = length(var.elasticache_clusters) > 0 ? 1 : 0

  name       = "${var.name}-elasticache-subnet-group"
  subnet_ids = module.vpc.elasticache_subnets

  tags = merge(local.common_tags, {
    Name = "${var.name}-elasticache-subnet-group"
  })
}

resource "aws_elasticache_cluster" "main" {
  for_each = var.elasticache_clusters

  cluster_id           = "${var.name}-${each.value.name}"
  engine               = each.value.engine
  node_type            = each.value.node_type
  num_cache_nodes      = each.value.num_cache_nodes
  parameter_group_name = each.value.parameter_group_name

  port = each.value.port

  subnet_group_name          = aws_elasticache_subnet_group.main[0].name
  security_group_ids         = each.value.security_group_ids
  preferred_availability_zones = each.value.preferred_availability_zones

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-cache"
  })
}

# ==============================================================================
# Lambda with VPC
# ==============================================================================

resource "aws_lambda_function" "vpc_lambda" {
  for_each = var.lambda_functions

  filename         = each.value.filename
  function_name    = "${var.name}-${each.value.name}"
  role            = aws_iam_role.lambda_role[each.key].arn
  handler         = each.value.handler
  runtime         = each.value.runtime
  timeout         = each.value.timeout
  memory_size     = each.value.memory_size

  vpc_config {
    subnet_ids         = each.value.subnet_ids
    security_group_ids = each.value.security_group_ids
  }

  environment {
    variables = each.value.environment_variables
  }

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-lambda"
  })
}

resource "aws_iam_role" "lambda_role" {
  for_each = var.lambda_functions

  name = "${var.name}-${each.value.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.common_tags, each.value.tags, {
    Name = "${var.name}-${each.value.name}-lambda-role"
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  for_each = var.lambda_functions

  role       = aws_iam_role.lambda_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  for_each = var.lambda_functions

  role       = aws_iam_role.lambda_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ==============================================================================
# EKS Cluster
# ==============================================================================

module "eks" {
  count = length(var.eks_node_groups) > 0 ? 1 : 0

  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.cluster_name
  cluster_version = var.eks_config.cluster_version

  cluster_endpoint_private_access = var.eks_config.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.eks_config.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.eks_config.cluster_endpoint_public_access_cidrs

  cluster_service_ipv4_cidr = var.eks_config.cluster_service_ipv4_cidr
  cluster_ip_family         = var.eks_config.cluster_ip_family

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = var.eks_config.enable_irsa

  # EKS Cluster Security Group
  cluster_security_group_additional_rules = {
    ingress_nodes_443 = {
      description                = "Node groups to cluster API"
      protocol                  = "tcp"
      from_port                 = 443
      to_port                   = 443
      type                      = "ingress"
      source_node_security_group = true
    }
  }

  # Node Security Group
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  # EKS Node Groups
  eks_managed_node_groups = {
    for name, config in var.eks_node_groups : name => {
      name = config.name

      instance_types = config.instance_types
      capacity_type  = config.capacity_type

      disk_size = config.disk_size
      disk_type = config.disk_type
      ami_type  = config.ami_type
      platform  = config.platform

      desired_size = config.desired_size
      max_size     = config.max_size
      min_size     = config.min_size

      max_unavailable = config.max_unavailable
      max_unavailable_percentage = config.max_unavailable_percentage

      force_update_version = config.force_update_version

      update_config = config.update_config

      labels = config.labels
      taints = config.taints

      tags = merge(local.common_tags, config.tags)
    }
  }

  # EKS Fargate Profiles
  fargate_profiles = {
    for name, config in var.eks_fargate_profiles : name => {
      name = config.name
      selectors = config.selectors
      subnets   = length(config.subnets) > 0 ? config.subnets : module.vpc.private_subnets
      tags      = merge(local.common_tags, config.tags)
    }
  }

  # CloudWatch Log Group
  create_cloudwatch_log_group = var.eks_config.create_cloudwatch_log_group
  cluster_log_retention_in_days = var.eks_config.cluster_log_retention_in_days
  cluster_log_types = var.eks_config.cluster_log_types

  # Cluster Creator Admin Permissions
  enable_cluster_creator_admin_permissions = var.eks_config.enable_cluster_creator_admin_permissions

  tags = local.common_tags
}

# ==============================================================================
# ECR Repositories
# ==============================================================================

resource "aws_ecr_repository" "repositories" {
  for_each = var.ecr_repositories

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  encryption_configuration {
    encryption_type = each.value.encryption_type
    kms_key         = each.value.kms_key_id
  }

  tags = merge(local.common_tags, each.value.tags)
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = {
    for name, repo in var.ecr_repositories : name => repo
    if repo.lifecycle_policy != null
  }

  repository = aws_ecr_repository.repositories[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.lifecycle_policy.max_image_count} images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = each.value.lifecycle_policy.max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove images older than ${each.value.lifecycle_policy.max_age_days} days"
        selection = {
          tagStatus   = "any"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.lifecycle_policy.max_age_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ==============================================================================
# ECR Repository Policy
# ==============================================================================

resource "aws_ecr_repository_policy" "repositories" {
  for_each = var.ecr_repositories

  repository = aws_ecr_repository.repositories[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromEKS"
        Effect = "Allow"
        Principal = {
          AWS = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_iam_role_arn : "*"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# ==============================================================================
# Kubernetes Provider Configuration
# ==============================================================================

provider "kubernetes" {
  host                   = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_endpoint : ""
  cluster_ca_certificate = length(var.eks_node_groups) > 0 ? base64decode(module.eks[0].cluster_certificate_authority_data) : ""
  token                  = length(var.eks_node_groups) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : ""

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      length(var.eks_node_groups) > 0 ? module.eks[0].cluster_name : ""
    ]
  }
}

provider "helm" {
  kubernetes {
    host                   = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_endpoint : ""
    cluster_ca_certificate = length(var.eks_node_groups) > 0 ? base64decode(module.eks[0].cluster_certificate_authority_data) : ""
    token                  = length(var.eks_node_groups) > 0 ? data.aws_eks_cluster_auth.cluster[0].token : ""

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        length(var.eks_node_groups) > 0 ? module.eks[0].cluster_name : ""
      ]
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  count = length(var.eks_node_groups) > 0 ? 1 : 0
  name  = module.eks[0].cluster_name
}

# ==============================================================================
# CloudWatch Container Insights
# ==============================================================================

resource "helm_release" "cloudwatch_container_insights" {
  count = var.enable_cloudwatch_container_insights && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "cloudwatch-container-insights"
  repository = "https://public.ecr.aws/cloudwatch-agent"
  chart      = "cloudwatch-agent"
  namespace  = "amazon-cloudwatch"
  create_namespace = true

  set {
    name  = "clusterName"
    value = module.eks[0].cluster_name
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  depends_on = [module.eks]
}

# ==============================================================================
# AWS Load Balancer Controller
# ==============================================================================

resource "helm_release" "aws_load_balancer_controller" {
  count = var.enable_aws_load_balancer_controller && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = module.eks[0].cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [module.eks]
}

# ==============================================================================
# Metrics Server
# ==============================================================================

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }

  depends_on = [module.eks]
}

# ==============================================================================
# Cluster Autoscaler
# ==============================================================================

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks[0].cluster_name
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  depends_on = [module.eks]
}

# ==============================================================================
# Network Policies
# ==============================================================================

resource "helm_release" "calico" {
  count = var.enable_network_policies && var.network_policy_provider == "calico" && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "calico"
  repository = "https://docs.tigera.io/calico/charts"
  chart      = "tigera-operator"
  namespace  = "tigera-operator"
  create_namespace = true

  depends_on = [module.eks]
}

resource "helm_release" "cilium" {
  count = var.enable_network_policies && var.network_policy_provider == "cilium" && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  namespace  = "kube-system"

  set {
    name  = "ipam.mode"
    value = "eni"
  }

  set {
    name  = "enableIPv4Masquerade"
    value = "false"
  }

  set {
    name  = "tunnel"
    value = "disabled"
  }

  depends_on = [module.eks]
}

# ==============================================================================
# Velero Backup
# ==============================================================================

resource "helm_release" "velero" {
  count = var.enable_velero_backup && length(var.eks_node_groups) > 0 ? 1 : 0

  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  namespace  = "velero"
  create_namespace = true

  set {
    name  = "configuration.provider"
    value = "aws"
  }

  set {
    name  = "configuration.backupStorageLocation.name"
    value = "default"
  }

  set {
    name  = "configuration.backupStorageLocation.bucket"
    value = var.velero_backup_config.backup_location_bucket
  }

  set {
    name  = "configuration.backupStorageLocation.config.region"
    value = var.velero_backup_config.backup_location_region
  }

  set {
    name  = "configuration.volumeSnapshotLocation.name"
    value = "default"
  }

  set {
    name  = "configuration.volumeSnapshotLocation.config.region"
    value = var.velero_backup_config.backup_location_region
  }

  set {
    name  = "schedules.daily.schedule"
    value = var.velero_backup_config.schedule
  }

  set {
    name  = "schedules.daily.template.ttl"
    value = "${var.velero_backup_config.retention_days}h"
  }

  depends_on = [module.eks]
}

# ==============================================================================
# Local Values for ALB Listeners
# ==============================================================================

locals {
  alb_listeners = flatten([
    for alb_key, alb in var.application_load_balancers : [
      for listener in alb.listeners : merge(listener, {
        alb_key = alb_key
        tags    = merge(local.common_tags, alb.tags, listener.tags)
      })
    ]
  ])
} 