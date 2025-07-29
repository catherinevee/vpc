# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR block must be a valid CIDR notation."
  }
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "custom-vpc"

  validation {
    condition     = length(var.vpc_name) > 0 && length(var.vpc_name) <= 255
    error_message = "VPC name must be between 1 and 255 characters."
  }
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Instance tenancy must be either 'default' or 'dedicated'."
  }
}

variable "ipv4_ipam_pool_id" {
  description = "The ID of an IPv4 IPAM pool you want to use for allocating this VPC's CIDR"
  type        = string
  default     = null
}

variable "ipv4_netmask_length" {
  description = "The netmask length of the IPv4 CIDR you want to allocate to this VPC"
  type        = number
  default     = null

  validation {
    condition     = var.ipv4_netmask_length == null || (var.ipv4_netmask_length >= 8 && var.ipv4_netmask_length <= 32)
    error_message = "IPv4 netmask length must be between 8 and 32."
  }
}

variable "ipv6_cidr_block" {
  description = "The IPv6 CIDR block for the VPC"
  type        = string
  default     = null

  validation {
    condition     = var.ipv6_cidr_block == null || can(cidrhost(var.ipv6_cidr_block, 0))
    error_message = "IPv6 CIDR block must be a valid CIDR notation."
  }
}

variable "ipv6_ipam_pool_id" {
  description = "The ID of an IPv6 IPAM pool you want to use for allocating this VPC's CIDR"
  type        = string
  default     = null
}

variable "ipv6_netmask_length" {
  description = "The netmask length of the IPv6 CIDR you want to allocate to this VPC"
  type        = number
  default     = null

  validation {
    condition     = var.ipv6_netmask_length == null || (var.ipv6_netmask_length >= 32 && var.ipv6_netmask_length <= 128)
    error_message = "IPv6 netmask length must be between 32 and 128."
  }
}

variable "ipv6_cidr_block_network_border_group" {
  description = "The name of the location from which we advertise the IPV6 CIDR block"
  type        = string
  default     = null
}

# IPv6 Configuration
variable "enable_ipv6" {
  description = "Should be true to enable IPv6 support in the VPC and subnets"
  type        = bool
  default     = false
}

variable "public_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for public subnets"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_ipv6_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet IPv6 CIDR blocks must be valid CIDR notation."
  }
}

variable "private_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for private subnets"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_ipv6_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private subnet IPv6 CIDR blocks must be valid CIDR notation."
  }
}

variable "database_subnet_ipv6_cidrs" {
  description = "List of IPv6 CIDR blocks for database subnets"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.database_subnet_ipv6_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All database subnet IPv6 CIDR blocks must be valid CIDR notation."
  }
}

# Subnet Configuration
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]

  validation {
    condition     = length(var.availability_zones) > 0 && length(var.availability_zones) <= 6
    error_message = "Availability zones must be between 1 and 6 zones."
  }
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition = alltrue([
      for subnet in var.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    condition = alltrue([
      for subnet in var.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for subnet in var.database_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All database subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "map_public_ip_on_launch" {
  description = "Should be true if you want to auto-assign public IP on launch"
  type        = bool
  default     = true
}

# Internet Gateway Configuration
variable "create_igw" {
  description = "Controls if an Internet Gateway is created for public subnets"
  type        = bool
  default     = true
}

# NAT Gateway Configuration
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = false
}

# Security Group Configuration
variable "create_default_security_group" {
  description = "Controls if default security group should be created"
  type        = bool
  default     = true
}

variable "default_security_group_ingress_rules" {
  description = "List of ingress rules for the default security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all traffic within VPC"
    }
  ]
}

variable "default_security_group_egress_rules" {
  description = "List of egress rules for the default security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

# Tags
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for key, value in var.tags : length(key) > 0 && length(key) <= 128
    ])
    error_message = "Tag keys must be between 1 and 128 characters."
  }
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type        = map(string)
  default     = {}
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

variable "database_subnet_tags" {
  description = "Additional tags for the database subnets"
  type        = map(string)
  default     = {}
} 

# EC2 Instance Configuration
variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "ec2-instance"

  validation {
    condition     = length(var.instance_name) > 0 && length(var.instance_name) <= 255
    error_message = "Instance name must be between 1 and 255 characters."
  }
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid AWS instance type."
  }
}

# AMI Configuration
variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  type        = string
  default     = null
}

variable "use_latest_ami" {
  description = "Whether to use the latest Amazon Linux 2 AMI"
  type        = bool
  default     = true
}

variable "ami_type" {
  description = "Type of AMI to use (amazon_linux_2, ubuntu, custom)"
  type        = string
  default     = "amazon_linux_2"

  validation {
    condition     = contains(["amazon_linux_2", "ubuntu", "custom"], var.ami_type)
    error_message = "AMI type must be one of: amazon_linux_2, ubuntu, custom."
  }
}

variable "custom_ami_id" {
  description = "Custom AMI ID to use"
  type        = string
  default     = null
}

variable "custom_ami_owner" {
  description = "Owner of the custom AMI"
  type        = string
  default     = "self"
}

# Network Configuration
variable "vpc_id" {
  description = "VPC ID where the EC2 instance will be created"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be created"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone for the EC2 instance"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = false
}

variable "private_ip" {
  description = "Private IP address for the EC2 instance"
  type        = string
  default     = null
}

# Security Group Configuration
variable "create_security_group" {
  description = "Whether to create a security group for the EC2 instance"
  type        = bool
  default     = true
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
  default     = []
}

variable "security_group_ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    self            = bool
  }))
  default = [
    {
      description     = "SSH access"
      from_port       = 22
      to_port         = 22
      protocol        = "tcp"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      self            = false
    }
  ]
}

variable "security_group_egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    description     = string
    from_port       = number
    to_port         = number
    protocol        = string
    cidr_blocks     = list(string)
    security_groups = list(string)
    self            = bool
  }))
  default = [
    {
      description     = "Allow all outbound traffic"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
      security_groups = []
      self            = false
    }
  ]
}

# Key Pair Configuration
variable "create_key_pair" {
  description = "Whether to create a key pair for SSH access"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Name of the key pair to use for SSH access"
  type        = string
  default     = null
}

variable "public_key" {
  description = "Public key for the key pair"
  type        = string
  default     = null
  sensitive   = true
}

# IAM Configuration
variable "create_iam_role" {
  description = "Whether to create an IAM role for the EC2 instance"
  type        = bool
  default     = false
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile to use"
  type        = string
  default     = null
}

variable "iam_policy_statements" {
  description = "List of IAM policy statements for the EC2 role"
  type = list(object({
    Effect    = string
    Action    = list(string)
    Resource  = list(string)
    Condition = map(any)
  }))
  default = []
}

# Launch Template Configuration
variable "use_launch_template" {
  description = "Whether to use a launch template instead of direct EC2 instance"
  type        = bool
  default     = false
}

variable "block_device_mappings" {
  description = "List of block device mappings for the launch template"
  type = list(object({
    device_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      throughput            = number
      volume_size           = number
      volume_type           = string
    })
  }))
  default = []
}

variable "network_interfaces" {
  description = "List of network interfaces for the launch template"
  type = list(object({
    associate_public_ip_address = bool
    delete_on_termination       = bool
    description                 = string
    device_index                = number
    network_interface_id        = string
    private_ip_address          = string
    subnet_id                   = string
    groups                      = list(string)
  }))
  default = []
}

# User Data Configuration
variable "user_data" {
  description = "User data script for the EC2 instance"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user data changes"
  type        = bool
  default     = false
}

# Block Device Configuration
variable "root_block_device" {
  description = "Root block device configuration"
  type = list(object({
    delete_on_termination = bool
    encrypted             = bool
    iops                  = number
    kms_key_id            = string
    volume_size           = number
    volume_type           = string
    throughput            = number
  }))
  default = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = null
      kms_key_id            = null
      volume_size           = 20
      volume_type           = "gp3"
      throughput            = null
    }
  ]
}

variable "ebs_block_device" {
  description = "List of EBS block devices"
  type = list(object({
    delete_on_termination = bool
    device_name           = string
    encrypted             = bool
    iops                  = number
    kms_key_id            = string
    snapshot_id           = string
    volume_size           = number
    volume_type           = string
    throughput            = number
  }))
  default = []
}

variable "ephemeral_block_device" {
  description = "List of ephemeral block devices"
  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
  }))
  default = []
}

# Monitoring Configuration
variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed monitoring"
  type        = bool
  default     = false
}

# Metadata Configuration
variable "metadata_options" {
  description = "Metadata options for the EC2 instance"
  type = object({
    http_endpoint               = string
    http_tokens                 = string
    http_put_response_hop_limit = number
    instance_metadata_tags      = string
  })
  default = null
}

# Instance Configuration
variable "source_dest_check" {
  description = "Whether to enable source/destination check"
  type        = bool
  default     = true
}

variable "disable_api_termination" {
  description = "Whether to disable API termination"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Shutdown behavior must be either 'stop' or 'terminate'."
  }
}

variable "placement_group" {
  description = "Placement group for the instance"
  type        = string
  default     = null
}

variable "tenancy" {
  description = "Tenancy of the instance"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.tenancy)
    error_message = "Tenancy must be either 'default' or 'dedicated'."
  }
}

variable "host_id" {
  description = "Host ID for the instance"
  type        = string
  default     = null
}

variable "cpu_core_count" {
  description = "Number of CPU cores for the instance"
  type        = number
  default     = null
}

variable "cpu_threads_per_core" {
  description = "Number of CPU threads per core"
  type        = number
  default     = null
}

variable "hibernation" {
  description = "Whether to enable hibernation"
  type        = bool
  default     = false
}

# Capacity Reservation Configuration
variable "capacity_reservation_preference" {
  description = "Capacity reservation preference"
  type        = string
  default     = "open"

  validation {
    condition     = contains(["open", "none"], var.capacity_reservation_preference)
    error_message = "Capacity reservation preference must be either 'open' or 'none'."
  }
}

variable "capacity_reservation_target" {
  description = "Capacity reservation target"
  type = object({
    capacity_reservation_id = string
  })
  default = null
}

# Auto Scaling Group Configuration
variable "create_autoscaling_group" {
  description = "Whether to create an Auto Scaling Group"
  type        = bool
  default     = false
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size for the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "asg_min_size" {
  description = "Minimum size for the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "asg_health_check_grace_period" {
  description = "Health check grace period for the Auto Scaling Group"
  type        = number
  default     = 300
}

variable "asg_health_check_type" {
  description = "Health check type for the Auto Scaling Group"
  type        = string
  default     = "EC2"

  validation {
    condition     = contains(["EC2", "ELB"], var.asg_health_check_type)
    error_message = "Health check type must be either 'EC2' or 'ELB'."
  }
}

variable "asg_subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "asg_tags" {
  description = "Tags for the Auto Scaling Group"
  type = list(object({
    key                 = string
    value               = string
    propagate_at_launch = bool
  }))
  default = []
}

variable "target_group_arns" {
  description = "List of target group ARNs for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "load_balancers" {
  description = "List of load balancer names for the Auto Scaling Group"
  type        = list(string)
  default     = []
}

variable "service_linked_role_arn" {
  description = "Service linked role ARN for the Auto Scaling Group"
  type        = string
  default     = null
}

variable "max_instance_lifetime" {
  description = "Maximum instance lifetime for the Auto Scaling Group"
  type        = number
  default     = null
}

variable "capacity_rebalance" {
  description = "Whether to enable capacity rebalancing"
  type        = bool
  default     = false
}

# Warm Pool Configuration
variable "warm_pool_state" {
  description = "State of the warm pool"
  type        = string
  default     = "Stopped"

  validation {
    condition     = contains(["Stopped", "Running"], var.warm_pool_state)
    error_message = "Warm pool state must be either 'Stopped' or 'Running'."
  }
}

variable "warm_pool_min_size" {
  description = "Minimum size for the warm pool"
  type        = number
  default     = 0
}

variable "warm_pool_max_group_prepared_capacity" {
  description = "Maximum group prepared capacity for the warm pool"
  type        = number
  default     = null
}

# Mixed Instances Policy Configuration
variable "mixed_instances_policy" {
  description = "Mixed instances policy for the Auto Scaling Group"
  type = object({
    instances_distribution = object({
      on_demand_base_capacity                  = number
      on_demand_percentage_above_base_capacity = number
      on_demand_allocation_strategy            = string
      spot_allocation_strategy                 = string
      spot_instance_pools                      = number
      spot_max_price                           = string
    })
    override = list(object({
      instance_type     = string
      weighted_capacity = number
    }))
  })
  default = null
}

# Instance Refresh Configuration
variable "instance_refresh" {
  description = "Instance refresh configuration for the Auto Scaling Group"
  type = object({
    strategy = string
    preferences = object({
      min_healthy_percentage = number
      max_healthy_percentage = number
      instance_warmup        = number
      checkpoint_percentages = list(number)
      checkpoint_delay       = number
      auto_rollback          = bool
      scale_in_protected_instances = string
      standby_instances      = string
    })
  })
  default = null
}

# Auto Scaling Policy Configuration
variable "asg_policies" {
  description = "Auto Scaling policies"
  type = map(object({
    name = string
    adjustment_type = string
    scaling_adjustment = number
    cooldown = number
    metric_aggregation_type = string
    min_adjustment_magnitude = number
    step_adjustment = list(object({
      metric_interval_lower_bound = number
      metric_interval_upper_bound = number
      scaling_adjustment          = number
    }))
    target_tracking_configuration = object({
      predefined_metric_type = string
      resource_label         = string
      target_value           = number
      disable_scale_in       = bool
    })
  }))
  default = {}
}

# CloudWatch Alarm Configuration
variable "cloudwatch_alarms" {
  description = "CloudWatch alarms for the Auto Scaling Group"
  type = map(object({
    alarm_name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    namespace = string
    period = number
    statistic = string
    threshold = number
    alarm_description = string
    alarm_actions = list(string)
    ok_actions = list(string)
    insufficient_data_actions = list(string)
    dimensions = list(object({
      name  = string
      value = string
    }))
  }))
  default = {}
} 