# ==============================================================================
# Network Information - For integration with other modules and services
# ==============================================================================

output "vpc_id" {
  description = "VPC identifier for resource placement and security group rules"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block for security group and routing configuration"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "VPC ARN for IAM policies and resource-based permissions"
  value       = module.vpc.vpc_arn
}

output "private_subnets" {
  description = "Private subnet IDs for application workloads and databases"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs for load balancers and NAT gateways"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "Database subnet IDs for RDS and other data services"
  value       = module.vpc.database_subnets
}

output "elasticache_subnets" {
  description = "Cache subnet IDs for Redis and Memcached clusters"
  value       = module.vpc.elasticache_subnets
}

output "redshift_subnets" {
  description = "Analytics subnet IDs for data warehouse clusters"
  value       = module.vpc.redshift_subnets
}

output "intra_subnets" {
  description = "Isolated subnet IDs for internal-only resources"
  value       = module.vpc.intra_subnets
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = module.vpc.private_subnet_arns
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = module.vpc.public_subnet_arns
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = module.vpc.database_subnet_arns
}

output "elasticache_subnet_arns" {
  description = "List of ARNs of ElastiCache subnets"
  value       = module.vpc.elasticache_subnet_arns
}

output "redshift_subnet_arns" {
  description = "List of ARNs of Redshift subnets"
  value       = module.vpc.redshift_subnet_arns
}

output "intra_subnet_arns" {
  description = "List of ARNs of intra subnets"
  value       = module.vpc.intra_subnet_arns
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "elasticache_subnets_cidr_blocks" {
  description = "List of cidr_blocks of ElastiCache subnets"
  value       = module.vpc.elasticache_subnets_cidr_blocks
}

output "redshift_subnets_cidr_blocks" {
  description = "List of cidr_blocks of Redshift subnets"
  value       = module.vpc.redshift_subnets_cidr_blocks
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = module.vpc.intra_subnets_cidr_blocks
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "nat_instance_ids" {
  description = "List of NAT Instance IDs"
  value       = module.vpc.nat_instance_ids
}

output "nat_instance_public_ips" {
  description = "List of public Elastic IPs created for NAT Gateway"
  value       = module.vpc.nat_instance_public_ips
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = module.vpc.igw_arn
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = module.vpc.default_route_table_id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.vpc.database_route_table_ids
}

# ==============================================================================
# Application Load Balancer Outputs
# ==============================================================================

output "application_load_balancer_ids" {
  description = "Map of Application Load Balancer IDs"
  value       = { for k, v in aws_lb.application : k => v.id }
}

output "application_load_balancer_arns" {
  description = "Map of Application Load Balancer ARNs"
  value       = { for k, v in aws_lb.application : k => v.arn }
}

output "application_load_balancer_dns_names" {
  description = "Map of Application Load Balancer DNS names"
  value       = { for k, v in aws_lb.application : k => v.dns_name }
}

output "application_load_balancer_zone_ids" {
  description = "Map of Application Load Balancer zone IDs"
  value       = { for k, v in aws_lb.application : k => v.zone_id }
}

output "application_load_balancer_target_group_arns" {
  description = "Map of Application Load Balancer target group ARNs"
  value       = { for k, v in aws_lb_target_group.application : k => v.arn }
}

output "application_load_balancer_listener_arns" {
  description = "Map of Application Load Balancer listener ARNs"
  value       = { for k, v in aws_lb_listener.application : k => v.arn }
}

# ==============================================================================
# RDS Outputs
# ==============================================================================

output "rds_instance_ids" {
  description = "Map of RDS instance IDs"
  value       = { for k, v in aws_db_instance.main : k => v.id }
}

output "rds_instance_arns" {
  description = "Map of RDS instance ARNs"
  value       = { for k, v in aws_db_instance.main : k => v.arn }
}

output "rds_instance_endpoints" {
  description = "Map of RDS instance endpoints"
  value       = { for k, v in aws_db_instance.main : k => v.endpoint }
}

output "rds_instance_addresses" {
  description = "Map of RDS instance addresses"
  value       = { for k, v in aws_db_instance.main : k => v.address }
}

output "rds_instance_ports" {
  description = "Map of RDS instance ports"
  value       = { for k, v in aws_db_instance.main : k => v.port }
}

output "rds_subnet_group_id" {
  description = "RDS subnet group ID"
  value       = length(var.rds_instances) > 0 ? aws_db_subnet_group.main[0].id : null
}

output "rds_subnet_group_arn" {
  description = "RDS subnet group ARN"
  value       = length(var.rds_instances) > 0 ? aws_db_subnet_group.main[0].arn : null
}

# ==============================================================================
# ElastiCache Outputs
# ==============================================================================

output "elasticache_cluster_ids" {
  description = "Map of ElastiCache cluster IDs"
  value       = { for k, v in aws_elasticache_cluster.main : k => v.id }
}

output "elasticache_cluster_arns" {
  description = "Map of ElastiCache cluster ARNs"
  value       = { for k, v in aws_elasticache_cluster.main : k => v.arn }
}

output "elasticache_cluster_addresses" {
  description = "Map of ElastiCache cluster addresses"
  value       = { for k, v in aws_elasticache_cluster.main : k => v.cache_nodes[0].address }
}

output "elasticache_cluster_ports" {
  description = "Map of ElastiCache cluster ports"
  value       = { for k, v in aws_elasticache_cluster.main : k => v.port }
}

output "elasticache_subnet_group_id" {
  description = "ElastiCache subnet group ID"
  value       = length(var.elasticache_clusters) > 0 ? aws_elasticache_subnet_group.main[0].id : null
}

output "elasticache_subnet_group_arn" {
  description = "ElastiCache subnet group ARN"
  value       = length(var.elasticache_clusters) > 0 ? aws_elasticache_subnet_group.main[0].arn : null
}

# ==============================================================================
# Lambda Outputs
# ==============================================================================

output "lambda_function_names" {
  description = "Map of Lambda function names"
  value       = { for k, v in aws_lambda_function.vpc_lambda : k => v.function_name }
}

output "lambda_function_arns" {
  description = "Map of Lambda function ARNs"
  value       = { for k, v in aws_lambda_function.vpc_lambda : k => v.arn }
}

output "lambda_function_invoke_arns" {
  description = "Map of Lambda function invoke ARNs"
  value       = { for k, v in aws_lambda_function.vpc_lambda : k => v.invoke_arn }
}

output "lambda_role_arns" {
  description = "Map of Lambda IAM role ARNs"
  value       = { for k, v in aws_iam_role.lambda_role : k => v.arn }
}

# ==============================================================================
# Security Groups Outputs
# ==============================================================================

output "eks_cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = length(var.eks_node_groups) > 0 ? aws_security_group.eks_cluster[0].id : null
}

output "eks_nodes_security_group_id" {
  description = "Security group ID attached to the EKS nodes"
  value       = length(var.eks_node_groups) > 0 ? aws_security_group.eks_nodes[0].id : null
}

output "custom_security_group_ids" {
  description = "Map of custom security group IDs"
  value       = { for k, v in aws_security_group.custom : k => v.id }
}

# ==============================================================================
# Container Platform - EKS cluster connection details
# ==============================================================================

output "cluster_id" {
  description = "EKS cluster identifier for kubectl and AWS CLI operations"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_id : null
}

output "cluster_arn" {
  description = "EKS cluster ARN for IAM policies and service integration"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_arn : null
}

output "cluster_certificate_authority_data" {
  description = "Base64 certificate for kubectl configuration"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_certificate_authority_data : null
}

output "cluster_endpoint" {
  description = "EKS API server endpoint for kubectl and CI/CD integration"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_endpoint : null
}

output "cluster_iam_role_name" {
  description = "EKS service role name for policy attachments"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_iam_role_name : null
}

output "cluster_iam_role_arn" {
  description = "EKS service role ARN for cross-account access and integrations"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_iam_role_arn : null
}

output "cluster_oidc_issuer_url" {
  description = "OpenID Connect provider URL for IAM roles for service accounts (IRSA)"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_oidc_issuer_url : null
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_platform_version : null
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_status : null
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_primary_security_group_id : null
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_security_group_id : null
}

output "cluster_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the cluster security group"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_security_group_arn : null
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].node_security_group_id : null
}

output "node_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the node shared security group"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].node_security_group_arn : null
}

output "cluster_cloudwatch_log_group_arn" {
  description = "Amazon Resource Name (ARN) of CloudWatch log group"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_cloudwatch_log_group_arn : null
}

output "cluster_cloudwatch_log_group_name" {
  description = "Name of CloudWatch log group"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].cluster_cloudwatch_log_group_name : null
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node groups"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].eks_managed_node_groups : {}
}

output "eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].eks_managed_node_groups_autoscaling_group_names : []
}

output "fargate_profiles" {
  description = "Map of EKS Fargate profiles"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].fargate_profiles : {}
}

output "fargate_profile_ids" {
  description = "EKS Cluster's Fargate Profile IDs"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].fargate_profile_ids : []
}

output "fargate_profile_arns" {
  description = "EKS Cluster's Fargate Profile ARNs"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].fargate_profile_arns : []
}

output "fargate_profile_statuses" {
  description = "EKS Cluster's Fargate Profile statuses"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].fargate_profile_statuses : []
}

# ==============================================================================
# Container Registry - ECR repository access information
# ==============================================================================

output "ecr_repository_urls" {
  description = "ECR repository URLs for docker push/pull and CI/CD pipelines"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.repository_url }
}

output "ecr_repository_arns" {
  description = "ECR repository ARNs for IAM policy configuration"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.arn }
}

output "ecr_repository_names" {
  description = "ECR repository names for programmatic access"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.name }
}

output "ecr_registry_id" {
  description = "ECR registry ID (AWS account ID) for docker login commands"
  value       = length(aws_ecr_repository.repositories) > 0 ? aws_ecr_repository.repositories[keys(aws_ecr_repository.repositories)[0]].registry_id : null
}

output "ecr_registry_url" {
  description = "ECR registry endpoint for docker login and image operations"
  value       = length(aws_ecr_repository.repositories) > 0 ? "${aws_ecr_repository.repositories[keys(aws_ecr_repository.repositories)[0]].registry_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com" : null
}

# ==============================================================================
# Kubernetes Configuration Outputs
# ==============================================================================

output "kubeconfig" {
  description = "Base64 encoded kubeconfig"
  value       = length(var.eks_node_groups) > 0 ? base64encode(module.eks[0].kubeconfig) : null
  sensitive   = true
}

output "kubeconfig_filename" {
  description = "The filename of the generated kubectl config"
  value       = length(var.eks_node_groups) > 0 ? module.eks[0].kubeconfig_filename : null
}

# ==============================================================================
# Helm Release Outputs
# ==============================================================================

output "cloudwatch_container_insights_status" {
  description = "Status of CloudWatch Container Insights Helm release"
  value       = var.enable_cloudwatch_container_insights && length(var.eks_node_groups) > 0 ? helm_release.cloudwatch_container_insights[0].status : null
}

output "aws_load_balancer_controller_status" {
  description = "Status of AWS Load Balancer Controller Helm release"
  value       = var.enable_aws_load_balancer_controller && length(var.eks_node_groups) > 0 ? helm_release.aws_load_balancer_controller[0].status : null
}

output "metrics_server_status" {
  description = "Status of Metrics Server Helm release"
  value       = var.enable_metrics_server && length(var.eks_node_groups) > 0 ? helm_release.metrics_server[0].status : null
}

output "cluster_autoscaler_status" {
  description = "Status of Cluster Autoscaler Helm release"
  value       = var.enable_cluster_autoscaler && length(var.eks_node_groups) > 0 ? helm_release.cluster_autoscaler[0].status : null
}

output "calico_status" {
  description = "Status of Calico Helm release"
  value       = var.enable_network_policies && var.network_policy_provider == "calico" && length(var.eks_node_groups) > 0 ? helm_release.calico[0].status : null
}

output "cilium_status" {
  description = "Status of Cilium Helm release"
  value       = var.enable_network_policies && var.network_policy_provider == "cilium" && length(var.eks_node_groups) > 0 ? helm_release.cilium[0].status : null
}

output "velero_status" {
  description = "Status of Velero Helm release"
  value       = var.enable_velero_backup && length(var.eks_node_groups) > 0 ? helm_release.velero[0].status : null
}

# ==============================================================================
# Common Outputs
# ==============================================================================

output "tags" {
  description = "A map of tags assigned to the resource"
  value       = local.common_tags
}

output "region" {
  description = "AWS region"
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  description = "ARN of the caller"
  value       = data.aws_caller_identity.current.arn
}

output "caller_user" {
  description = "Unique identifier of the calling entity"
  value       = data.aws_caller_identity.current.user_id
} 