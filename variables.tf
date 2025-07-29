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