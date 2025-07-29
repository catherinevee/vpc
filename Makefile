# Makefile for EC2 Terraform Module
# Usage: make <target>

.PHONY: help init plan apply destroy fmt validate lint clean test examples

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Create Terraform plan"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  fmt       - Format Terraform code"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  lint      - Run TFLint"
	@echo "  clean     - Clean up Terraform files"
	@echo "  test      - Run tests"
	@echo "  examples  - Run examples"
	@echo "  docs      - Generate documentation"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init
	@echo "Terraform initialized successfully!"

# Create Terraform plan
plan:
	@echo "Creating Terraform plan..."
	terraform plan -out=tfplan
	@echo "Plan created successfully!"

# Apply Terraform changes
apply:
	@echo "Applying Terraform changes..."
	terraform apply tfplan
	@echo "Changes applied successfully!"

# Apply Terraform changes (auto-approve)
apply-auto:
	@echo "Applying Terraform changes (auto-approve)..."
	terraform apply -auto-approve
	@echo "Changes applied successfully!"

# Destroy Terraform resources
destroy:
	@echo "Destroying Terraform resources..."
	terraform destroy -auto-approve
	@echo "Resources destroyed successfully!"

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	terraform fmt -recursive
	@echo "Code formatted successfully!"

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "Configuration is valid!"

# Run TFLint
lint:
	@echo "Running TFLint..."
	tflint --init
	tflint
	@echo "Linting completed!"

# Clean up Terraform files
clean:
	@echo "Cleaning up Terraform files..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f tfplan
	rm -f *.tfstate
	rm -f *.tfstate.backup
	@echo "Cleanup completed!"

# Run tests
test: validate lint
	@echo "Running tests..."
	cd test && terraform init
	cd test && terraform plan -detailed-exitcode
	@echo "Tests completed!"

# Run examples
examples:
	@echo "Running examples..."
	cd examples && terraform init
	cd examples && terraform plan -detailed-exitcode
	@echo "Examples completed!"

# Development workflow
dev: fmt validate lint
	@echo "Development checks completed!"

# Production workflow
prod: fmt validate lint test examples
	@echo "Production checks completed!"

# Install dependencies
install:
	@echo "Installing dependencies..."
	curl -sSLo ~/.local/bin/tflint https://github.com/terraform-linters/tflint/releases/latest/download/tflint_linux_amd64
	chmod +x ~/.local/bin/tflint
	@echo "Dependencies installed successfully!"

# Show current workspace
workspace:
	@echo "Current workspace: $(shell terraform workspace show)"

# List workspaces
workspaces:
	@echo "Available workspaces:"
	@terraform workspace list

# Create new workspace
workspace-new:
	@read -p "Enter workspace name: " name; \
	terraform workspace new $$name

# Switch workspace
workspace-switch:
	@read -p "Enter workspace name: " name; \
	terraform workspace select $$name

# Generate documentation
docs:
	@echo "Generating documentation..."
	terraform-docs markdown table . > README.md
	@echo "Documentation generated successfully!"

# Security scan
security:
	@echo "Running security scan..."
	terrascan scan
	@echo "Security scan completed!"

# Cost estimation
cost:
	@echo "Estimating costs..."
	terraform plan -out=tfplan
	terraform show -json tfplan | jq '.planned_values.root_module.resources[] | select(.type == "aws_instance") | {address: .address, type: .type, values: .values}'
	@echo "Cost estimation completed!"

# Backup state
backup:
	@echo "Backing up Terraform state..."
	cp *.tfstate *.tfstate.backup.$(shell date +%Y%m%d_%H%M%S)
	@echo "State backup completed!"

# Restore state
restore:
	@echo "Available backups:"
	@ls -la *.tfstate.backup.*
	@read -p "Enter backup file to restore: " backup; \
	cp $$backup *.tfstate
	@echo "State restored successfully!"

# Show outputs
outputs:
	@echo "Terraform outputs:"
	@terraform output

# Show resources
resources:
	@echo "Terraform resources:"
	@terraform state list

# Import resource
import:
	@read -p "Enter resource address: " address; \
	read -p "Enter resource ID: " id; \
	terraform import $$address $$id
	@echo "Resource imported successfully!"

# Refresh state
refresh:
	@echo "Refreshing Terraform state..."
	terraform refresh
	@echo "State refreshed successfully!"

# Show plan
show-plan:
	@echo "Showing Terraform plan..."
	terraform show tfplan

# Show state
show-state:
	@echo "Showing Terraform state..."
	terraform show

# Lock state
lock:
	@echo "Locking Terraform state..."
	terraform force-unlock -force

# Unlock state
unlock:
	@echo "Unlocking Terraform state..."
	@read -p "Enter lock ID: " lock_id; \
	terraform force-unlock $$lock_id

# Validate variables
validate-vars:
	@echo "Validating variables..."
	terraform validate -var-file=variables.tfvars
	@echo "Variables validated successfully!"

# Plan with variables
plan-vars:
	@echo "Creating Terraform plan with variables..."
	terraform plan -var-file=variables.tfvars -out=tfplan
	@echo "Plan created successfully!"

# Apply with variables
apply-vars:
	@echo "Applying Terraform changes with variables..."
	terraform apply -var-file=variables.tfvars
	@echo "Changes applied successfully!"

# Destroy with variables
destroy-vars:
	@echo "Destroying Terraform resources with variables..."
	terraform destroy -var-file=variables.tfvars -auto-approve
	@echo "Resources destroyed successfully!"

# Show module usage
usage:
	@echo "Module usage examples:"
	@echo ""
	@echo "Basic EC2 instance:"
	@echo "module \"ec2\" {"
	@echo "  source = \"./ec2-module\""
	@echo "  instance_name = \"my-instance\""
	@echo "  instance_type = \"t3.micro\""
	@echo "  subnet_id     = \"subnet-12345678\""
	@echo "}"
	@echo ""
	@echo "EC2 instance with Auto Scaling Group:"
	@echo "module \"ec2\" {"
	@echo "  source = \"./ec2-module\""
	@echo "  instance_name = \"my-instance\""
	@echo "  instance_type = \"t3.micro\""
	@echo "  use_launch_template = true"
	@echo "  create_autoscaling_group = true"
	@echo "  asg_desired_capacity = 2"
	@echo "  asg_max_size = 5"
	@echo "  asg_min_size = 1"
	@echo "  asg_subnet_ids = [\"subnet-12345678\", \"subnet-87654321\"]"
	@echo "}" 