# Test outputs for the VPC module

output "test_vpc_id" {
  description = "Test VPC ID"
  value       = module.vpc_test.vpc_id
}

output "test_public_subnets" {
  description = "Test public subnet IDs"
  value       = module.vpc_test.public_subnet_ids
}

output "test_private_subnets" {
  description = "Test private subnet IDs"
  value       = module.vpc_test.private_subnet_ids
}

output "test_nat_gateways" {
  description = "Test NAT Gateway IDs"
  value       = module.vpc_test.nat_gateway_ids
} 