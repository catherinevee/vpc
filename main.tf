# Custom EC2 Module using AWS Provider
# Based on HashiCorp AWS Provider resources

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  count = var.use_latest_ami ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  count = var.ami_type == "ubuntu" ? 1 : 0

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for custom AMI
data "aws_ami" "custom" {
  count = var.custom_ami_id != null ? 1 : 0

  owners = [var.custom_ami_owner]

  filter {
    name   = "image-id"
    values = [var.custom_ami_id]
  }
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.instance_name}-sg"
  vpc_id      = var.vpc_id
  description = "Security group for ${var.instance_name} EC2 instance"

  dynamic "ingress" {
    for_each = var.security_group_ingress_rules
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
      security_groups  = lookup(ingress.value, "security_groups", null)
      self             = lookup(ingress.value, "self", null)
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress_rules
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = lookup(egress.value, "cidr_blocks", null)
      security_groups  = lookup(egress.value, "security_groups", null)
      self             = lookup(egress.value, "self", null)
    }
  }

  tags = merge(
    {
      Name = "${var.instance_name}-sg"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Key Pair for SSH access
resource "aws_key_pair" "ec2" {
  count = var.create_key_pair ? 1 : 0

  key_name_prefix = "${var.instance_name}-key"
  public_key      = var.public_key

  tags = merge(
    {
      Name = "${var.instance_name}-key"
    },
    var.tags
  )
}

# IAM Role for EC2 instance
resource "aws_iam_role" "ec2" {
  count = var.create_iam_role ? 1 : 0

  name_prefix = "${var.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.instance_name}-role"
    },
    var.tags
  )
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  count = var.create_iam_role ? 1 : 0

  name_prefix = "${var.instance_name}-profile"
  role        = aws_iam_role.ec2[0].name

  tags = merge(
    {
      Name = "${var.instance_name}-profile"
    },
    var.tags
  )
}

# IAM Policy for EC2 role
resource "aws_iam_role_policy" "ec2" {
  count = var.create_iam_role && length(var.iam_policy_statements) > 0 ? 1 : 0

  name_prefix = "${var.instance_name}-policy"
  role        = aws_iam_role.ec2[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = var.iam_policy_statements
  })
}

# Launch Template
resource "aws_launch_template" "ec2" {
  count = var.use_launch_template ? 1 : 0

  name_prefix = "${var.instance_name}-lt"

  image_id      = local.ami_id
  instance_type = var.instance_type

  key_name = var.create_key_pair ? aws_key_pair.ec2[0].key_name : var.key_name

  vpc_security_group_ids = var.create_security_group ? [aws_security_group.ec2[0].id] : var.security_group_ids

  iam_instance_profile {
    name = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.iam_instance_profile_name
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name

      ebs {
        delete_on_termination = lookup(block_device_mappings.value.ebs, "delete_on_termination", true)
        encrypted             = lookup(block_device_mappings.value.ebs, "encrypted", true)
        iops                  = lookup(block_device_mappings.value.ebs, "iops", null)
        kms_key_id            = lookup(block_device_mappings.value.ebs, "kms_key_id", null)
        snapshot_id           = lookup(block_device_mappings.value.ebs, "snapshot_id", null)
        throughput            = lookup(block_device_mappings.value.ebs, "throughput", null)
        volume_size           = lookup(block_device_mappings.value.ebs, "volume_size", 20)
        volume_type           = lookup(block_device_mappings.value.ebs, "volume_type", "gp3")
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_public_ip_address = lookup(network_interfaces.value, "associate_public_ip_address", false)
      delete_on_termination       = lookup(network_interfaces.value, "delete_on_termination", true)
      description                 = lookup(network_interfaces.value, "description", null)
      device_index                = lookup(network_interfaces.value, "device_index", 0)
      network_interface_id        = lookup(network_interfaces.value, "network_interface_id", null)
      private_ip_address          = lookup(network_interfaces.value, "private_ip_address", null)
      subnet_id                   = lookup(network_interfaces.value, "subnet_id", var.subnet_id)
      groups                      = lookup(network_interfaces.value, "groups", null)
    }
  }

  user_data = base64encode(var.user_data)

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", 1)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_detailed_monitoring ? [1] : []
    content {
      enabled = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      {
        Name = var.instance_name
      },
      var.tags
    )
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(
      {
        Name = "${var.instance_name}-volume"
      },
      var.tags
    )
  }

  tags = merge(
    {
      Name = "${var.instance_name}-lt"
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# EC2 Instance (when not using launch template)
resource "aws_instance" "ec2" {
  count = var.use_launch_template ? 0 : var.instance_count

  ami           = local.ami_id
  instance_type = var.instance_type

  availability_zone = var.availability_zone
  subnet_id         = var.subnet_id

  key_name = var.create_key_pair ? aws_key_pair.ec2[0].key_name : var.key_name

  vpc_security_group_ids = var.create_security_group ? [aws_security_group.ec2[0].id] : var.security_group_ids

  iam_instance_profile = var.create_iam_role ? aws_iam_instance_profile.ec2[0].name : var.iam_instance_profile_name

  associate_public_ip_address = var.associate_public_ip_address

  private_ip = var.private_ip != null ? var.private_ip : null

  user_data = var.user_data

  user_data_replace_on_change = var.user_data_replace_on_change

  dynamic "root_block_device" {
    for_each = var.root_block_device
    content {
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      encrypted             = lookup(root_block_device.value, "encrypted", true)
      iops                  = lookup(root_block_device.value, "iops", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      volume_size           = lookup(root_block_device.value, "volume_size", 20)
      volume_type           = lookup(root_block_device.value, "volume_type", "gp3")
      throughput            = lookup(root_block_device.value, "throughput", null)
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_device
    content {
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      device_name           = ebs_block_device.value.device_name
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      throughput            = lookup(ebs_block_device.value, "throughput", null)
    }
  }

  dynamic "ephemeral_block_device" {
    for_each = var.ephemeral_block_device
    content {
      device_name  = ephemeral_block_device.value.device_name
      no_device    = lookup(ephemeral_block_device.value, "no_device", null)
      virtual_name = lookup(ephemeral_block_device.value, "virtual_name", null)
    }
  }

  monitoring = var.enable_detailed_monitoring

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? [var.metadata_options] : []
    content {
      http_endpoint               = lookup(metadata_options.value, "http_endpoint", "enabled")
      http_tokens                 = lookup(metadata_options.value, "http_tokens", "required")
      http_put_response_hop_limit = lookup(metadata_options.value, "http_put_response_hop_limit", 1)
      instance_metadata_tags      = lookup(metadata_options.value, "instance_metadata_tags", "disabled")
    }
  }

  dynamic "network_interface" {
    for_each = var.network_interfaces
    content {
      device_index          = lookup(network_interface.value, "device_index", 0)
      network_interface_id  = lookup(network_interface.value, "network_interface_id", null)
      delete_on_termination = lookup(network_interface.value, "delete_on_termination", true)
    }
  }

  source_dest_check = var.source_dest_check

  disable_api_termination = var.disable_api_termination

  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  placement_group = var.placement_group

  tenancy = var.tenancy

  host_id = var.host_id

  cpu_core_count = var.cpu_core_count

  cpu_threads_per_core = var.cpu_threads_per_core

  hibernation = var.hibernation

  capacity_reservation_specification {
    capacity_reservation_preference = var.capacity_reservation_preference
  }

  dynamic "capacity_reservation_specification" {
    for_each = var.capacity_reservation_target != null ? [var.capacity_reservation_target] : []
    content {
      capacity_reservation_target {
        capacity_reservation_id = capacity_reservation_specification.value.capacity_reservation_id
      }
    }
  }

  tags = merge(
    {
      Name = var.instance_count > 1 ? "${var.instance_name}-${count.index + 1}" : var.instance_name
    },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2" {
  count = var.create_autoscaling_group ? 1 : 0

  name_prefix = "${var.instance_name}-asg"

  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  health_check_grace_period = var.asg_health_check_grace_period
  health_check_type         = var.asg_health_check_type
  vpc_zone_identifier       = var.asg_subnet_ids

  launch_template {
    id      = aws_launch_template.ec2[0].id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = lookup(tag, "propagate_at_launch", true)
    }
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  target_group_arns = var.target_group_arns

  load_balancers = var.load_balancers

  placement_group = var.placement_group

  service_linked_role_arn = var.service_linked_role_arn

  max_instance_lifetime = var.max_instance_lifetime

  capacity_rebalance = var.capacity_rebalance

  warm_pool {
    pool_state                  = var.warm_pool_state
    min_size                    = var.warm_pool_min_size
    max_group_prepared_capacity = var.warm_pool_max_group_prepared_capacity
  }

  dynamic "mixed_instances_policy" {
    for_each = var.mixed_instances_policy != null ? [var.mixed_instances_policy] : []
    content {
      instances_distribution {
        on_demand_base_capacity                  = lookup(mixed_instances_policy.value.instances_distribution, "on_demand_base_capacity", 0)
        on_demand_percentage_above_base_capacity = lookup(mixed_instances_policy.value.instances_distribution, "on_demand_percentage_above_base_capacity", 100)
        on_demand_allocation_strategy            = lookup(mixed_instances_policy.value.instances_distribution, "on_demand_allocation_strategy", null)
        spot_allocation_strategy                 = lookup(mixed_instances_policy.value.instances_distribution, "spot_allocation_strategy", null)
        spot_instance_pools                      = lookup(mixed_instances_policy.value.instances_distribution, "spot_instance_pools", null)
        spot_max_price                           = lookup(mixed_instances_policy.value.instances_distribution, "spot_max_price", null)
      }

      launch_template {
        launch_template_specification {
          launch_template_id   = aws_launch_template.ec2[0].id
          launch_template_name = aws_launch_template.ec2[0].name
          version              = "$Latest"
        }

        dynamic "override" {
          for_each = lookup(mixed_instances_policy.value, "override", [])
          content {
            instance_type     = override.value.instance_type
            weighted_capacity = lookup(override.value, "weighted_capacity", null)
          }
        }
      }
    }
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh != null ? [var.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      preferences {
        min_healthy_percentage = lookup(instance_refresh.value.preferences, "min_healthy_percentage", null)
        max_healthy_percentage = lookup(instance_refresh.value.preferences, "max_healthy_percentage", null)
        instance_warmup        = lookup(instance_refresh.value.preferences, "instance_warmup", null)
        checkpoint_percentages = lookup(instance_refresh.value.preferences, "checkpoint_percentages", null)
        checkpoint_delay       = lookup(instance_refresh.value.preferences, "checkpoint_delay", null)
        auto_rollback          = lookup(instance_refresh.value.preferences, "auto_rollback", null)
        scale_in_protected_instances = lookup(instance_refresh.value.preferences, "scale_in_protected_instances", null)
        standby_instances      = lookup(instance_refresh.value.preferences, "standby_instances", null)
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "ec2" {
  for_each = var.create_autoscaling_group && length(var.asg_policies) > 0 ? var.asg_policies : {}

  name                   = each.value.name
  autoscaling_group_name = aws_autoscaling_group.ec2[0].name
  adjustment_type        = each.value.adjustment_type
  scaling_adjustment     = each.value.scaling_adjustment
  cooldown               = lookup(each.value, "cooldown", null)
  metric_aggregation_type = lookup(each.value, "metric_aggregation_type", null)
  min_adjustment_magnitude = lookup(each.value, "min_adjustment_magnitude", null)

  dynamic "step_adjustment" {
    for_each = lookup(each.value, "step_adjustment", [])
    content {
      metric_interval_lower_bound = lookup(step_adjustment.value, "metric_interval_lower_bound", null)
      metric_interval_upper_bound = lookup(step_adjustment.value, "metric_interval_upper_bound", null)
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
    }
  }

  dynamic "target_tracking_configuration" {
    for_each = lookup(each.value, "target_tracking_configuration", null) != null ? [each.value.target_tracking_configuration] : []
    content {
      predefined_metric_specification {
        predefined_metric_type = target_tracking_configuration.value.predefined_metric_type
        resource_label         = lookup(target_tracking_configuration.value, "resource_label", null)
      }
      target_value = target_tracking_configuration.value.target_value
      disable_scale_in = lookup(target_tracking_configuration.value, "disable_scale_in", false)
    }
  }
}

# CloudWatch Alarm for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "ec2" {
  for_each = var.create_autoscaling_group && length(var.cloudwatch_alarms) > 0 ? var.cloudwatch_alarms : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = lookup(each.value, "alarm_description", null)
  alarm_actions       = lookup(each.value, "alarm_actions", null)
  ok_actions          = lookup(each.value, "ok_actions", null)
  insufficient_data_actions = lookup(each.value, "insufficient_data_actions", null)

  dimensions = lookup(each.value, "dimensions", null)
}

# Local values for AMI selection
locals {
  ami_id = var.custom_ami_id != null ? data.aws_ami.custom[0].id : (
    var.ami_type == "ubuntu" ? data.aws_ami.ubuntu[0].id : (
      var.use_latest_ami ? data.aws_ami.amazon_linux_2[0].id : var.ami_id
    )
  )
} 