# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = var.create_igw ? aws_internet_gateway.main[0].id : null
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "List of IDs of database subnets"
  value       = aws_subnet.database[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public[*].arn
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private[*].arn
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = aws_subnet.database[*].arn
}

# Route Table Outputs
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for NAT Gateway"
  value       = aws_eip.nat[*].public_ip
}

# Security Group Outputs
output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = var.create_default_security_group ? aws_security_group.default[0].id : null
}

# Availability Zones
output "availability_zones" {
  description = "List of availability zones used"
  value       = var.availability_zones
}

# Network ACLs (if you want to add them later)
output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.main.main_route_table_id
}

# IPv6 Outputs
output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the VPC"
  value       = aws_vpc.main.ipv6_cidr_block
}

output "vpc_ipv6_cidr_block_network_border_group" {
  description = "The IPv6 CIDR block network border group"
  value       = aws_vpc.main.ipv6_cidr_block_network_border_group
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = aws_vpc.main.ipv6_association_id
}

output "public_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of public subnets"
  value       = aws_subnet.public[*].ipv6_cidr_block
}

output "private_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of private subnets"
  value       = aws_subnet.private[*].ipv6_cidr_block
}

output "database_subnet_ipv6_cidr_blocks" {
  description = "List of IPv6 CIDR blocks of database subnets"
  value       = aws_subnet.database[*].ipv6_cidr_block
} 

# EC2 Instance Outputs
output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.ec2[*].id
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = aws_instance.ec2[*].arn
}

output "instance_public_ips" {
  description = "List of public IP addresses of the EC2 instances"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses of the EC2 instances"
  value       = aws_instance.ec2[*].private_ip
}

output "instance_public_dns" {
  description = "List of public DNS names of the EC2 instances"
  value       = aws_instance.ec2[*].public_dns
}

output "instance_private_dns" {
  description = "List of private DNS names of the EC2 instances"
  value       = aws_instance.ec2[*].private_dns
}

output "instance_availability_zones" {
  description = "List of availability zones of the EC2 instances"
  value       = aws_instance.ec2[*].availability_zone
}

output "instance_subnet_ids" {
  description = "List of subnet IDs of the EC2 instances"
  value       = aws_instance.ec2[*].subnet_id
}

output "instance_vpc_security_group_ids" {
  description = "List of VPC security group IDs of the EC2 instances"
  value       = aws_instance.ec2[*].vpc_security_group_ids
}

output "instance_root_block_device" {
  description = "List of root block device configurations of the EC2 instances"
  value       = aws_instance.ec2[*].root_block_device
}

output "instance_ebs_block_device" {
  description = "List of EBS block device configurations of the EC2 instances"
  value       = aws_instance.ec2[*].ebs_block_device
}

output "instance_metadata_options" {
  description = "List of metadata options of the EC2 instances"
  value       = aws_instance.ec2[*].metadata_options
}

output "instance_iam_instance_profile" {
  description = "List of IAM instance profiles of the EC2 instances"
  value       = aws_instance.ec2[*].iam_instance_profile
}

output "instance_key_name" {
  description = "List of key names of the EC2 instances"
  value       = aws_instance.ec2[*].key_name
}

output "instance_placement_group" {
  description = "List of placement groups of the EC2 instances"
  value       = aws_instance.ec2[*].placement_group
}

output "instance_tenancy" {
  description = "List of tenancy configurations of the EC2 instances"
  value       = aws_instance.ec2[*].tenancy
}

output "instance_host_id" {
  description = "List of host IDs of the EC2 instances"
  value       = aws_instance.ec2[*].host_id
}

output "instance_cpu_core_count" {
  description = "List of CPU core counts of the EC2 instances"
  value       = aws_instance.ec2[*].cpu_core_count
}

output "instance_cpu_threads_per_core" {
  description = "List of CPU threads per core of the EC2 instances"
  value       = aws_instance.ec2[*].cpu_threads_per_core
}

output "instance_hibernation" {
  description = "List of hibernation configurations of the EC2 instances"
  value       = aws_instance.ec2[*].hibernation
}

output "instance_capacity_reservation_specification" {
  description = "List of capacity reservation specifications of the EC2 instances"
  value       = aws_instance.ec2[*].capacity_reservation_specification
}

output "instance_source_dest_check" {
  description = "List of source/destination check configurations of the EC2 instances"
  value       = aws_instance.ec2[*].source_dest_check
}

output "instance_disable_api_termination" {
  description = "List of API termination disable configurations of the EC2 instances"
  value       = aws_instance.ec2[*].disable_api_termination
}

output "instance_instance_initiated_shutdown_behavior" {
  description = "List of instance initiated shutdown behaviors of the EC2 instances"
  value       = aws_instance.ec2[*].instance_initiated_shutdown_behavior
}

output "instance_monitoring" {
  description = "List of monitoring configurations of the EC2 instances"
  value       = aws_instance.ec2[*].monitoring
}

output "instance_network_interface" {
  description = "List of network interface configurations of the EC2 instances"
  value       = aws_instance.ec2[*].network_interface
}

output "instance_primary_network_interface_id" {
  description = "List of primary network interface IDs of the EC2 instances"
  value       = aws_instance.ec2[*].primary_network_interface_id
}

output "instance_secondary_private_ips" {
  description = "List of secondary private IP addresses of the EC2 instances"
  value       = aws_instance.ec2[*].secondary_private_ips
}

output "instance_secondary_private_ip_address_count" {
  description = "List of secondary private IP address counts of the EC2 instances"
  value       = aws_instance.ec2[*].secondary_private_ip_address_count
}

output "instance_tags" {
  description = "List of tags of the EC2 instances"
  value       = aws_instance.ec2[*].tags
}

output "instance_tags_all" {
  description = "List of all tags of the EC2 instances"
  value       = aws_instance.ec2[*].tags_all
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].id : null
}

output "security_group_arn" {
  description = "ARN of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].arn : null
}

output "security_group_name" {
  description = "Name of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].name : null
}

output "security_group_description" {
  description = "Description of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].description : null
}

output "security_group_vpc_id" {
  description = "VPC ID of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].vpc_id : null
}

output "security_group_owner_id" {
  description = "Owner ID of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].owner_id : null
}

output "security_group_tags" {
  description = "Tags of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].tags : null
}

output "security_group_tags_all" {
  description = "All tags of the security group created for the EC2 instance"
  value       = var.create_security_group ? aws_security_group.ec2[0].tags_all : null
}

# Key Pair Outputs
output "key_pair_id" {
  description = "ID of the key pair created for the EC2 instance"
  value       = var.create_key_pair ? aws_key_pair.ec2[0].id : null
}

output "key_pair_name" {
  description = "Name of the key pair created for the EC2 instance"
  value       = var.create_key_pair ? aws_key_pair.ec2[0].key_name : null
}

output "key_pair_fingerprint" {
  description = "Fingerprint of the key pair created for the EC2 instance"
  value       = var.create_key_pair ? aws_key_pair.ec2[0].fingerprint : null
}

output "key_pair_tags" {
  description = "Tags of the key pair created for the EC2 instance"
  value       = var.create_key_pair ? aws_key_pair.ec2[0].tags : null
}

output "key_pair_tags_all" {
  description = "All tags of the key pair created for the EC2 instance"
  value       = var.create_key_pair ? aws_key_pair.ec2[0].tags_all : null
}

# IAM Role Outputs
output "iam_role_id" {
  description = "ID of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].id : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].arn : null
}

output "iam_role_name" {
  description = "Name of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].name : null
}

output "iam_role_unique_id" {
  description = "Unique ID of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].unique_id : null
}

output "iam_role_tags" {
  description = "Tags of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].tags : null
}

output "iam_role_tags_all" {
  description = "All tags of the IAM role created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_role.ec2[0].tags_all : null
}

# IAM Instance Profile Outputs
output "iam_instance_profile_id" {
  description = "ID of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].id : null
}

output "iam_instance_profile_arn" {
  description = "ARN of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : null
}

output "iam_instance_profile_role" {
  description = "Role of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].role : null
}

output "iam_instance_profile_tags" {
  description = "Tags of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].tags : null
}

output "iam_instance_profile_tags_all" {
  description = "All tags of the IAM instance profile created for the EC2 instance"
  value       = var.create_iam_role ? aws_iam_instance_profile.ec2[0].tags_all : null
}

# IAM Role Policy Outputs
output "iam_role_policy_id" {
  description = "ID of the IAM role policy created for the EC2 instance"
  value       = var.create_iam_role && length(var.iam_policy_statements) > 0 ? aws_iam_role_policy.ec2[0].id : null
}

output "iam_role_policy_name" {
  description = "Name of the IAM role policy created for the EC2 instance"
  value       = var.create_iam_role && length(var.iam_policy_statements) > 0 ? aws_iam_role_policy.ec2[0].name : null
}

output "iam_role_policy_role" {
  description = "Role of the IAM role policy created for the EC2 instance"
  value       = var.create_iam_role && length(var.iam_policy_statements) > 0 ? aws_iam_role_policy.ec2[0].role : null
}

output "iam_role_policy_policy" {
  description = "Policy of the IAM role policy created for the EC2 instance"
  value       = var.create_iam_role && length(var.iam_policy_statements) > 0 ? aws_iam_role_policy.ec2[0].policy : null
}

# Launch Template Outputs
output "launch_template_id" {
  description = "ID of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].id : null
}

output "launch_template_arn" {
  description = "ARN of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].arn : null
}

output "launch_template_name" {
  description = "Name of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].name : null
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].latest_version : null
}

output "launch_template_default_version" {
  description = "Default version of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].default_version : null
}

output "launch_template_tags" {
  description = "Tags of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].tags : null
}

output "launch_template_tags_all" {
  description = "All tags of the launch template created for the EC2 instance"
  value       = var.use_launch_template ? aws_launch_template.ec2[0].tags_all : null
}

# Auto Scaling Group Outputs
output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].id : null
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].arn : null
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].name : null
}

output "autoscaling_group_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].desired_capacity : null
}

output "autoscaling_group_max_size" {
  description = "Maximum size of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].max_size : null
}

output "autoscaling_group_min_size" {
  description = "Minimum size of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].min_size : null
}

output "autoscaling_group_health_check_grace_period" {
  description = "Health check grace period of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].health_check_grace_period : null
}

output "autoscaling_group_health_check_type" {
  description = "Health check type of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].health_check_type : null
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "VPC zone identifier of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].vpc_zone_identifier : null
}

output "autoscaling_group_target_group_arns" {
  description = "Target group ARNs of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].target_group_arns : null
}

output "autoscaling_group_load_balancers" {
  description = "Load balancers of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].load_balancers : null
}

output "autoscaling_group_placement_group" {
  description = "Placement group of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].placement_group : null
}

output "autoscaling_group_service_linked_role_arn" {
  description = "Service linked role ARN of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].service_linked_role_arn : null
}

output "autoscaling_group_max_instance_lifetime" {
  description = "Maximum instance lifetime of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].max_instance_lifetime : null
}

output "autoscaling_group_capacity_rebalance" {
  description = "Capacity rebalance of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].capacity_rebalance : null
}

output "autoscaling_group_warm_pool" {
  description = "Warm pool configuration of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].warm_pool : null
}

output "autoscaling_group_mixed_instances_policy" {
  description = "Mixed instances policy of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].mixed_instances_policy : null
}

output "autoscaling_group_instance_refresh" {
  description = "Instance refresh configuration of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].instance_refresh : null
}

output "autoscaling_group_tags" {
  description = "Tags of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].tags : null
}

output "autoscaling_group_tags_all" {
  description = "All tags of the Auto Scaling Group created for the EC2 instance"
  value       = var.create_autoscaling_group ? aws_autoscaling_group.ec2[0].tags_all : null
}

# Auto Scaling Policy Outputs
output "autoscaling_policy_ids" {
  description = "IDs of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.id] : []
}

output "autoscaling_policy_arns" {
  description = "ARNs of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.arn] : []
}

output "autoscaling_policy_names" {
  description = "Names of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.name] : []
}

output "autoscaling_policy_autoscaling_group_names" {
  description = "Auto Scaling group names of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.autoscaling_group_name] : []
}

output "autoscaling_policy_adjustment_types" {
  description = "Adjustment types of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.adjustment_type] : []
}

output "autoscaling_policy_scaling_adjustments" {
  description = "Scaling adjustments of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.scaling_adjustment] : []
}

output "autoscaling_policy_cooldowns" {
  description = "Cooldowns of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.cooldown] : []
}

output "autoscaling_policy_metric_aggregation_types" {
  description = "Metric aggregation types of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.metric_aggregation_type] : []
}

output "autoscaling_policy_min_adjustment_magnitudes" {
  description = "Minimum adjustment magnitudes of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.min_adjustment_magnitude] : []
}

output "autoscaling_policy_step_adjustments" {
  description = "Step adjustments of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.step_adjustment] : []
}

output "autoscaling_policy_target_tracking_configurations" {
  description = "Target tracking configurations of the Auto Scaling policies created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.asg_policies) > 0 ? [for policy in aws_autoscaling_policy.ec2 : policy.target_tracking_configuration] : []
}

# CloudWatch Alarm Outputs
output "cloudwatch_alarm_ids" {
  description = "IDs of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.id] : []
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.arn] : []
}

output "cloudwatch_alarm_names" {
  description = "Names of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.alarm_name] : []
}

output "cloudwatch_alarm_comparison_operators" {
  description = "Comparison operators of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.comparison_operator] : []
}

output "cloudwatch_alarm_evaluation_periods" {
  description = "Evaluation periods of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.evaluation_periods] : []
}

output "cloudwatch_alarm_metric_names" {
  description = "Metric names of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.metric_name] : []
}

output "cloudwatch_alarm_namespaces" {
  description = "Namespaces of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.namespace] : []
}

output "cloudwatch_alarm_periods" {
  description = "Periods of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.period] : []
}

output "cloudwatch_alarm_statistics" {
  description = "Statistics of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.statistic] : []
}

output "cloudwatch_alarm_thresholds" {
  description = "Thresholds of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.threshold] : []
}

output "cloudwatch_alarm_alarm_descriptions" {
  description = "Alarm descriptions of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.alarm_description] : []
}

output "cloudwatch_alarm_alarm_actions" {
  description = "Alarm actions of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.alarm_actions] : []
}

output "cloudwatch_alarm_ok_actions" {
  description = "OK actions of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.ok_actions] : []
}

output "cloudwatch_alarm_insufficient_data_actions" {
  description = "Insufficient data actions of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.insufficient_data_actions] : []
}

output "cloudwatch_alarm_dimensions" {
  description = "Dimensions of the CloudWatch alarms created for the EC2 instance"
  value       = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? [for alarm in aws_cloudwatch_metric_alarm.ec2 : alarm.dimensions] : []
}

# AMI Outputs
output "ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = local.ami_id
}

output "amazon_linux_2_ami_id" {
  description = "Amazon Linux 2 AMI ID"
  value       = var.use_latest_ami ? data.aws_ami.amazon_linux_2[0].id : null
}

output "ubuntu_ami_id" {
  description = "Ubuntu AMI ID"
  value       = var.ami_type == "ubuntu" ? data.aws_ami.ubuntu[0].id : null
}

output "custom_ami_id" {
  description = "Custom AMI ID"
  value       = var.custom_ami_id != null ? data.aws_ami.custom[0].id : null
}

# Local Values Outputs
output "local_ami_id" {
  description = "Local AMI ID value"
  value       = local.ami_id
} 