# Test outputs for the EC2 module

# Basic EC2 Instance Test Outputs
output "test_basic_ec2_instance_id" {
  description = "ID of the test basic EC2 instance"
  value       = module.test_basic_ec2.instance_ids[0]
}

output "test_basic_ec2_security_group_id" {
  description = "ID of the security group for the test basic EC2 instance"
  value       = module.test_basic_ec2.security_group_id
}

# Launch Template Test Outputs
output "test_launch_template_id" {
  description = "ID of the test launch template"
  value       = module.test_launch_template.launch_template_id
}

output "test_launch_template_name" {
  description = "Name of the test launch template"
  value       = module.test_launch_template.launch_template_name
}

output "test_launch_template_security_group_id" {
  description = "ID of the security group for the test launch template"
  value       = module.test_launch_template.security_group_id
}

# IAM Role Test Outputs
output "test_iam_role_arn" {
  description = "ARN of the test IAM role"
  value       = module.test_iam_ec2.iam_role_arn
}

output "test_iam_role_name" {
  description = "Name of the test IAM role"
  value       = module.test_iam_ec2.iam_role_name
}

output "test_iam_instance_profile_name" {
  description = "Name of the test IAM instance profile"
  value       = module.test_iam_ec2.iam_instance_profile_name
}

output "test_iam_ec2_security_group_id" {
  description = "ID of the security group for the test IAM EC2 instance"
  value       = module.test_iam_ec2.security_group_id
}

# Multiple EC2 Instances Test Outputs
output "test_multiple_ec2_instance_ids" {
  description = "IDs of the test multiple EC2 instances"
  value       = module.test_multiple_ec2.instance_ids
}

output "test_multiple_ec2_security_group_id" {
  description = "ID of the security group for the test multiple EC2 instances"
  value       = module.test_multiple_ec2.security_group_id
}

# AMI Test Outputs
output "test_amazon_linux_2_ami_id" {
  description = "Amazon Linux 2 AMI ID used in tests"
  value       = module.test_basic_ec2.amazon_linux_2_ami_id
}

# Summary Test Outputs
output "test_all_instance_ids" {
  description = "All test EC2 instance IDs"
  value = concat(
    module.test_basic_ec2.instance_ids,
    module.test_multiple_ec2.instance_ids
  )
}

output "test_all_security_group_ids" {
  description = "All test security group IDs"
  value = compact([
    module.test_basic_ec2.security_group_id,
    module.test_launch_template.security_group_id,
    module.test_iam_ec2.security_group_id,
    module.test_multiple_ec2.security_group_id
  ])
}

output "test_all_iam_role_arns" {
  description = "All test IAM role ARNs"
  value = compact([
    module.test_iam_ec2.iam_role_arn
  ])
}

output "test_all_launch_template_ids" {
  description = "All test launch template IDs"
  value = compact([
    module.test_launch_template.launch_template_id
  ])
} 