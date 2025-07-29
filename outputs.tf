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