# ==============================================================================
# Core Variables - Required for all deployments
# ==============================================================================

variable "name" {
  description = "Resource name prefix - used for naming all AWS resources"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Name must start with letter, contain only alphanumeric chars and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment - affects resource sizing and configuration"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "tags" {
  description = "Resource tags applied to all AWS resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Network Configuration - VPC and subnet setup
# ==============================================================================

variable "vpc_config" {
  description = "VPC network configuration - controls NAT gateway costs and connectivity"
  type = object({
    cidr_block           = string
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)
    enable_nat_gateway   = optional(bool, true)
    single_nat_gateway   = optional(bool, false)  # Set true for dev to save costs
    one_nat_gateway_per_az = optional(bool, false)  # Set true for prod HA
    enable_vpn_gateway   = optional(bool, false)
    enable_flow_log      = optional(bool, false)  # Enable for security auditing
    flow_log_retention_in_days = optional(number, 7)
    # Enhanced VPC configuration options
    enable_ipv6 = optional(bool, false)
    assign_ipv6_address_on_creation = optional(bool, false)
    enable_classiclink = optional(bool, false)
    enable_classiclink_dns_support = optional(bool, false)
    enable_network_address_usage_metrics = optional(bool, false)
    # NAT Gateway configuration
    nat_gateway_destination_cidr_block = optional(string, "0.0.0.0/0")
    nat_gateway_connectivity_type = optional(string, "public")
    nat_gateway_allocation_ids = optional(list(string), [])
    nat_gateway_private_ip = optional(string, null)
    nat_gateway_subnet_id = optional(string, null)
    # VPN Gateway configuration
    vpn_gateway_amazon_side_asn = optional(number, 64512)
    vpn_gateway_availability_zone = optional(string, null)
    # Flow Log configuration
    flow_log_destination_type = optional(string, "cloud-watch-logs")
    flow_log_destination_arn = optional(string, null)
    flow_log_iam_role_arn = optional(string, null)
    flow_log_log_format = optional(string, null)
    flow_log_max_aggregation_interval = optional(number, 600)
    flow_log_traffic_type = optional(string, "ALL")
    # VPC Endpoints
    enable_s3_endpoint = optional(bool, false)
    enable_dynamodb_endpoint = optional(bool, false)
    enable_ec2_endpoint = optional(bool, false)
    enable_ec2messages_endpoint = optional(bool, false)
    enable_ssm_endpoint = optional(bool, false)
    enable_ssmmessages_endpoint = optional(bool, false)
    enable_ecr_api_endpoint = optional(bool, false)
    enable_ecr_dkr_endpoint = optional(bool, false)
    enable_ecs_endpoint = optional(bool, false)
    enable_ecs_agent_endpoint = optional(bool, false)
    enable_ecs_telemetry_endpoint = optional(bool, false)
    enable_elasticloadbalancing_endpoint = optional(bool, false)
    enable_events_endpoint = optional(bool, false)
    enable_logs_endpoint = optional(bool, false)
    enable_monitoring_endpoint = optional(bool, false)
    enable_sqs_endpoint = optional(bool, false)
    enable_sns_endpoint = optional(bool, false)
    enable_sts_endpoint = optional(bool, false)
    enable_transfer_endpoint = optional(bool, false)
    enable_transferserver_endpoint = optional(bool, false)
    enable_autoscaling_endpoint = optional(bool, false)
    enable_elasticache_endpoint = optional(bool, false)
    enable_rds_endpoint = optional(bool, false)
    enable_secretsmanager_endpoint = optional(bool, false)
    enable_kms_endpoint = optional(bool, false)
    enable_glue_endpoint = optional(bool, false)
    enable_athena_endpoint = optional(bool, false)
    enable_emr_endpoint = optional(bool, false)
    enable_emrcontainers_endpoint = optional(bool, false)
    enable_emrserverless_endpoint = optional(bool, false)
    enable_workspaces_endpoint = optional(bool, false)
    enable_workspaces_web_endpoint = optional(bool, false)
    enable_codepipeline_endpoint = optional(bool, false)
    enable_codebuild_endpoint = optional(bool, false)
    enable_codedeploy_endpoint = optional(bool, false)
    enable_codedeploy_commands_secure_endpoint = optional(bool, false)
    enable_codestar_connections_endpoint = optional(bool, false)
    enable_codestar_notifications_endpoint = optional(bool, false)
    enable_git_codecommit_endpoint = optional(bool, false)
    enable_config_endpoint = optional(bool, false)
    enable_config_rules_endpoint = optional(bool, false)
    enable_config_recorder_endpoint = optional(bool, false)
    enable_cloudformation_endpoint = optional(bool, false)
    enable_cloudtrail_endpoint = optional(bool, false)
    enable_cloudwatch_endpoint = optional(bool, false)
    enable_cloudwatch_events_endpoint = optional(bool, false)
    enable_cloudwatch_logs_endpoint = optional(bool, false)
    enable_cloudwatch_monitoring_endpoint = optional(bool, false)
    enable_application_autoscaling_endpoint = optional(bool, false)
    enable_autoscaling_plans_endpoint = optional(bool, false)
    enable_batch_endpoint = optional(bool, false)
    enable_ce_endpoint = optional(bool, false)
    enable_clouddirectory_endpoint = optional(bool, false)
    enable_cloudsearch_endpoint = optional(bool, false)
    enable_cloudsearchdomain_endpoint = optional(bool, false)
    enable_cloudtrail_endpoint = optional(bool, false)
    enable_codeartifact_endpoint = optional(bool, false)
    enable_codebuild_endpoint = optional(bool, false)
    enable_codecommit_endpoint = optional(bool, false)
    enable_codedeploy_endpoint = optional(bool, false)
    enable_codepipeline_endpoint = optional(bool, false)
    enable_codestar_endpoint = optional(bool, false)
    enable_cognito_identity_endpoint = optional(bool, false)
    enable_cognito_idp_endpoint = optional(bool, false)
    enable_cognito_sync_endpoint = optional(bool, false)
    enable_comprehend_endpoint = optional(bool, false)
    enable_comprehendmedical_endpoint = optional(bool, false)
    enable_config_endpoint = optional(bool, false)
    enable_connect_endpoint = optional(bool, false)
    enable_connectparticipant_endpoint = optional(bool, false)
    enable_cur_endpoint = optional(bool, false)
    enable_databrew_endpoint = optional(bool, false)
    enable_dataexchange_endpoint = optional(bool, false)
    enable_datapipeline_endpoint = optional(bool, false)
    enable_datasync_endpoint = optional(bool, false)
    enable_dax_endpoint = optional(bool, false)
    enable_devicefarm_endpoint = optional(bool, false)
    enable_directconnect_endpoint = optional(bool, false)
    enable_dlm_endpoint = optional(bool, false)
    enable_dms_endpoint = optional(bool, false)
    enable_docdb_endpoint = optional(bool, false)
    enable_ds_endpoint = optional(bool, false)
    enable_dynamodb_endpoint = optional(bool, false)
    enable_ec2_endpoint = optional(bool, false)
    enable_ec2messages_endpoint = optional(bool, false)
    enable_ecr_api_endpoint = optional(bool, false)
    enable_ecr_dkr_endpoint = optional(bool, false)
    enable_ecs_endpoint = optional(bool, false)
    enable_ecs_agent_endpoint = optional(bool, false)
    enable_ecs_telemetry_endpoint = optional(bool, false)
    enable_efs_endpoint = optional(bool, false)
    enable_eks_endpoint = optional(bool, false)
    enable_elasticache_endpoint = optional(bool, false)
    enable_elasticbeanstalk_endpoint = optional(bool, false)
    enable_elasticbeanstalk_health_endpoint = optional(bool, false)
    enable_elasticfilesystem_endpoint = optional(bool, false)
    enable_elasticloadbalancing_endpoint = optional(bool, false)
    enable_elasticmapreduce_endpoint = optional(bool, false)
    enable_elastictranscoder_endpoint = optional(bool, false)
    enable_elb_endpoint = optional(bool, false)
    enable_elbv2_endpoint = optional(bool, false)
    enable_emr_endpoint = optional(bool, false)
    enable_emrcontainers_endpoint = optional(bool, false)
    enable_emrserverless_endpoint = optional(bool, false)
    enable_es_endpoint = optional(bool, false)
    enable_events_endpoint = optional(bool, false)
    enable_firehose_endpoint = optional(bool, false)
    enable_fms_endpoint = optional(bool, false)
    enable_fsx_endpoint = optional(bool, false)
    enable_gamelift_endpoint = optional(bool, false)
    enable_glacier_endpoint = optional(bool, false)
    enable_globalaccelerator_endpoint = optional(bool, false)
    enable_glue_endpoint = optional(bool, false)
    enable_greengrass_endpoint = optional(bool, false)
    enable_guardduty_endpoint = optional(bool, false)
    enable_health_endpoint = optional(bool, false)
    enable_iam_endpoint = optional(bool, false)
    enable_identitystore_endpoint = optional(bool, false)
    enable_imagebuilder_endpoint = optional(bool, false)
    enable_inspector_endpoint = optional(bool, false)
    enable_iot_endpoint = optional(bool, false)
    enable_iot_analytics_endpoint = optional(bool, false)
    enable_iot_data_endpoint = optional(bool, false)
    enable_iot_jobs_data_endpoint = optional(bool, false)
    enable_iotsecuredtunneling_endpoint = optional(bool, false)
    enable_iotsitewise_endpoint = optional(bool, false)
    enable_kafka_endpoint = optional(bool, false)
    enable_kinesis_endpoint = optional(bool, false)
    enable_kinesis_analytics_endpoint = optional(bool, false)
    enable_kinesis_analytics_v2_endpoint = optional(bool, false)
    enable_kinesis_firehose_endpoint = optional(bool, false)
    enable_kinesis_video_streams_endpoint = optional(bool, false)
    enable_kms_endpoint = optional(bool, false)
    enable_lakeformation_endpoint = optional(bool, false)
    enable_lambda_endpoint = optional(bool, false)
    enable_license_manager_endpoint = optional(bool, false)
    enable_logs_endpoint = optional(bool, false)
    enable_machinelearning_endpoint = optional(bool, false)
    enable_macie_endpoint = optional(bool, false)
    enable_macie2_endpoint = optional(bool, false)
    enable_managedblockchain_endpoint = optional(bool, false)
    enable_marketplacecommerceanalytics_endpoint = optional(bool, false)
    enable_mediaconnect_endpoint = optional(bool, false)
    enable_mediaconvert_endpoint = optional(bool, false)
    enable_medialive_endpoint = optional(bool, false)
    enable_mediapackage_endpoint = optional(bool, false)
    enable_mediastore_endpoint = optional(bool, false)
    enable_mediastore_data_endpoint = optional(bool, false)
    enable_mediatailor_endpoint = optional(bool, false)
    enable_meteringmarketplace_endpoint = optional(bool, false)
    enable_migrationhub_endpoint = optional(bool, false)
    enable_mobile_endpoint = optional(bool, false)
    enable_mq_endpoint = optional(bool, false)
    enable_mturk_endpoint = optional(bool, false)
    enable_neptune_endpoint = optional(bool, false)
    enable_networkmanager_endpoint = optional(bool, false)
    enable_opsworks_endpoint = optional(bool, false)
    enable_opsworks_cm_endpoint = optional(bool, false)
    enable_organizations_endpoint = optional(bool, false)
    enable_outposts_endpoint = optional(bool, false)
    enable_personalize_endpoint = optional(bool, false)
    enable_personalize_events_endpoint = optional(bool, false)
    enable_personalize_runtime_endpoint = optional(bool, false)
    enable_pi_endpoint = optional(bool, false)
    enable_pinpoint_endpoint = optional(bool, false)
    enable_pinpoint_email_endpoint = optional(bool, false)
    enable_polly_endpoint = optional(bool, false)
    enable_pricing_endpoint = optional(bool, false)
    enable_qldb_endpoint = optional(bool, false)
    enable_quicksight_endpoint = optional(bool, false)
    enable_ram_endpoint = optional(bool, false)
    enable_rds_endpoint = optional(bool, false)
    enable_rds_data_endpoint = optional(bool, false)
    enable_redshift_endpoint = optional(bool, false)
    enable_redshift_data_endpoint = optional(bool, false)
    enable_rekognition_endpoint = optional(bool, false)
    enable_resource_groups_endpoint = optional(bool, false)
    enable_resourcegroupstaggingapi_endpoint = optional(bool, false)
    enable_robomaker_endpoint = optional(bool, false)
    enable_route53_endpoint = optional(bool, false)
    enable_route53resolver_endpoint = optional(bool, false)
    enable_s3_endpoint = optional(bool, false)
    enable_s3control_endpoint = optional(bool, false)
    enable_s3outposts_endpoint = optional(bool, false)
    enable_sagemaker_endpoint = optional(bool, false)
    enable_sagemaker_runtime_endpoint = optional(bool, false)
    enable_sagemaker_a2i_runtime_endpoint = optional(bool, false)
    enable_savingsplans_endpoint = optional(bool, false)
    enable_schemas_endpoint = optional(bool, false)
    enable_sdb_endpoint = optional(bool, false)
    enable_secretsmanager_endpoint = optional(bool, false)
    enable_securityhub_endpoint = optional(bool, false)
    enable_serverlessrepo_endpoint = optional(bool, false)
    enable_servicecatalog_endpoint = optional(bool, false)
    enable_servicecatalog_appregistry_endpoint = optional(bool, false)
    enable_servicediscovery_endpoint = optional(bool, false)
    enable_servicequotas_endpoint = optional(bool, false)
    enable_ses_endpoint = optional(bool, false)
    enable_ses_v2_endpoint = optional(bool, false)
    enable_shield_endpoint = optional(bool, false)
    enable_signer_endpoint = optional(bool, false)
    enable_sms_endpoint = optional(bool, false)
    enable_snowball_endpoint = optional(bool, false)
    enable_sns_endpoint = optional(bool, false)
    enable_sqs_endpoint = optional(bool, false)
    enable_ssm_endpoint = optional(bool, false)
    enable_ssmmessages_endpoint = optional(bool, false)
    enable_sso_endpoint = optional(bool, false)
    enable_sso_oidc_endpoint = optional(bool, false)
    enable_stepfunctions_endpoint = optional(bool, false)
    enable_storagegateway_endpoint = optional(bool, false)
    enable_sts_endpoint = optional(bool, false)
    enable_support_endpoint = optional(bool, false)
    enable_swf_endpoint = optional(bool, false)
    enable_synthetics_endpoint = optional(bool, false)
    enable_textract_endpoint = optional(bool, false)
    enable_timestream_endpoint = optional(bool, false)
    enable_transcribe_endpoint = optional(bool, false)
    enable_transfer_endpoint = optional(bool, false)
    enable_transferserver_endpoint = optional(bool, false)
    enable_translate_endpoint = optional(bool, false)
    enable_waf_endpoint = optional(bool, false)
    enable_waf_regional_endpoint = optional(bool, false)
    enable_wafv2_endpoint = optional(bool, false)
    enable_workdocs_endpoint = optional(bool, false)
    enable_worklink_endpoint = optional(bool, false)
    enable_workmail_endpoint = optional(bool, false)
    enable_workspaces_endpoint = optional(bool, false)
    enable_workspaces_web_endpoint = optional(bool, false)
    enable_xray_endpoint = optional(bool, false)
  })
  validation {
    condition     = can(cidrhost(var.vpc_config.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = object({
    public_subnets  = list(string)
    private_subnets = list(string)
    database_subnets = optional(list(string), [])
    elasticache_subnets = optional(list(string), [])
    redshift_subnets = optional(list(string), [])
    intra_subnets = optional(list(string), [])
    azs             = list(string)
    # Enhanced subnet configuration options
    map_public_ip_on_launch = optional(bool, true)
    map_customer_owned_ip_on_launch = optional(bool, false)
    customer_owned_ipv4_pool = optional(string, null)
    assign_ipv6_address_on_creation = optional(bool, false)
    enable_dns64 = optional(bool, false)
    enable_resource_name_dns_a_record_on_launch = optional(bool, false)
    enable_resource_name_dns_aaaa_record_on_launch = optional(bool, false)
    # Subnet-specific configurations
    public_subnet_ipv6_prefixes = optional(list(string), [])
    private_subnet_ipv6_prefixes = optional(list(string), [])
    database_subnet_ipv6_prefixes = optional(list(string), [])
    elasticache_subnet_ipv6_prefixes = optional(list(string), [])
    redshift_subnet_ipv6_prefixes = optional(list(string), [])
    intra_subnet_ipv6_prefixes = optional(list(string), [])
    # Route table configurations
    create_public_subnet_route_table = optional(bool, true)
    create_private_subnet_route_table = optional(bool, true)
    create_database_subnet_route_table = optional(bool, true)
    create_elasticache_subnet_route_table = optional(bool, true)
    create_redshift_subnet_route_table = optional(bool, true)
    create_intra_subnet_route_table = optional(bool, true)
    # NAT Gateway configurations
    nat_gateway_destination_cidr_block = optional(string, "0.0.0.0/0")
    nat_gateway_connectivity_type = optional(string, "public")
    nat_gateway_allocation_ids = optional(list(string), [])
    nat_gateway_private_ip = optional(string, null)
    nat_gateway_subnet_id = optional(string, null)
    # VPN Gateway configurations
    vpn_gateway_amazon_side_asn = optional(number, 64512)
    vpn_gateway_availability_zone = optional(string, null)
    # Internet Gateway configurations
    create_igw = optional(bool, true)
    igw_tags = optional(map(string), {})
    # Route table configurations
    public_route_table_tags = optional(map(string), {})
    private_route_table_tags = optional(map(string), {})
    database_route_table_tags = optional(map(string), {})
    elasticache_route_table_tags = optional(map(string), {})
    redshift_route_table_tags = optional(map(string), {})
    intra_route_table_tags = optional(map(string), {})
    # Subnet group configurations
    create_database_subnet_group = optional(bool, true)
    create_elasticache_subnet_group = optional(bool, true)
    create_redshift_subnet_group = optional(bool, true)
    database_subnet_group_name = optional(string, null)
    elasticache_subnet_group_name = optional(string, null)
    redshift_subnet_group_name = optional(string, null)
    database_subnet_group_tags = optional(map(string), {})
    elasticache_subnet_group_tags = optional(map(string), {})
    redshift_subnet_group_tags = optional(map(string), {})
  })
  validation {
    condition = alltrue([
      for subnet in var.subnet_config.public_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All public subnet CIDR blocks must be valid IPv4 CIDRs."
  }
  validation {
    condition = alltrue([
      for subnet in var.subnet_config.private_subnets : can(cidrhost(subnet, 0))
    ])
    error_message = "All private subnet CIDR blocks must be valid IPv4 CIDRs."
  }
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for private subnets"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Application Load Balancer Variables
# ==============================================================================

variable "application_load_balancers" {
  description = "Application Load Balancer configuration"
  type = map(object({
    name = string
    internal = optional(bool, false)
    security_groups = list(string)
    enable_deletion_protection = optional(bool, false)
    enable_http2 = optional(bool, true)
    access_logs_bucket = optional(string, null)
    access_logs_prefix = optional(string, "")
    # Enhanced ALB configuration options
    load_balancer_type = optional(string, "application")
    enable_cross_zone_load_balancing = optional(bool, false)
    enable_waf_fail_open = optional(bool, false)
    enable_tls_version_and_cipher_suite_headers = optional(bool, false)
    enable_xff_client_port = optional(bool, false)
    enable_xff_header_processing = optional(bool, false)
    xff_header_processing_mode = optional(string, "append")
    preserve_host_header = optional(bool, false)
    drop_invalid_header_fields = optional(bool, false)
    desync_mitigation_mode = optional(string, "defensive")
    desync_mitigation_mode_audit = optional(bool, false)
    desync_mitigation_mode_strict = optional(bool, false)
    desync_mitigation_mode_monitor = optional(bool, false)
    desync_mitigation_mode_defensive = optional(bool, true)
    desync_mitigation_mode_audit_strict = optional(bool, false)
    desync_mitigation_mode_audit_monitor = optional(bool, false)
    desync_mitigation_mode_audit_defensive = optional(bool, false)
    desync_mitigation_mode_strict_monitor = optional(bool, false)
    desync_mitigation_mode_strict_defensive = optional(bool, false)
    desync_mitigation_mode_monitor_defensive = optional(bool, false)
    desync_mitigation_mode_audit_strict_monitor = optional(bool, false)
    desync_mitigation_mode_audit_strict_defensive = optional(bool, false)
    desync_mitigation_mode_audit_monitor_defensive = optional(bool, false)
    desync_mitigation_mode_strict_monitor_defensive = optional(bool, false)
    desync_mitigation_mode_audit_strict_monitor_defensive = optional(bool, false)
    # Access logs configuration
    access_logs_enabled = optional(bool, false)
    access_logs_s3_bucket_force_destroy = optional(bool, false)
    access_logs_s3_bucket_versioning = optional(string, "Enabled")
    access_logs_s3_bucket_server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm = string
          kms_master_key_id = optional(string, null)
        })
      })
    }), null)
    # Target group configuration
    target_group = object({
      port = number
      protocol = string
      target_type = string
      vpc_id = optional(string, null)
      # Enhanced target group options
      deregistration_delay = optional(number, 300)
      slow_start = optional(number, 0)
      load_balancing_algorithm_type = optional(string, "round_robin")
      stickiness = optional(object({
        type = string
        cookie_duration = optional(number, 86400)
        cookie_name = optional(string, null)
      }), null)
      health_check = object({
        enabled = optional(bool, true)
        healthy_threshold = optional(number, 2)
        interval = optional(number, 30)
        matcher = optional(string, "200")
        path = optional(string, "/")
        port = optional(string, "traffic-port")
        protocol = optional(string, "HTTP")
        timeout = optional(number, 5)
        unhealthy_threshold = optional(number, 2)
        # Enhanced health check options
        success_codes = optional(string, "200")
        health_check_port = optional(string, "traffic-port")
        health_check_protocol = optional(string, "HTTP")
        health_check_path = optional(string, "/")
        health_check_interval = optional(number, 30)
        health_check_timeout = optional(number, 5)
        healthy_threshold_count = optional(number, 2)
        unhealthy_threshold_count = optional(number, 2)
        health_check_grace_period = optional(number, 300)
        health_check_healthy_threshold = optional(number, 2)
        health_check_unhealthy_threshold = optional(number, 2)
        health_check_matcher = optional(string, "200")
        health_check_success_codes = optional(string, "200")
        health_check_port_override = optional(string, null)
        health_check_protocol_override = optional(string, null)
        health_check_path_override = optional(string, null)
        health_check_interval_override = optional(number, null)
        health_check_timeout_override = optional(number, null)
        health_check_healthy_threshold_override = optional(number, null)
        health_check_unhealthy_threshold_override = optional(number, null)
        health_check_matcher_override = optional(string, null)
        health_check_success_codes_override = optional(string, null)
      })
    })
    # Listener configuration
    listeners = list(object({
      port = number
      protocol = string
      ssl_policy = optional(string, null)
      certificate_arn = optional(string, null)
      alpn_policy = optional(string, null)
      # Enhanced listener options
      default_action = object({
        type = string
        target_group_arn = optional(string, null)
        forward = optional(object({
          target_groups = list(object({
            arn = string
            weight = optional(number, 1)
          }))
          stickiness = optional(object({
            duration = number
            enabled = optional(bool, false)
          }), null)
        }), null)
        redirect = optional(object({
          path = optional(string, null)
          host = optional(string, null)
          port = optional(string, null)
          protocol = optional(string, null)
          query = optional(string, null)
          status_code = string
        }), null)
        fixed_response = optional(object({
          content_type = string
          message_body = optional(string, null)
          status_code = optional(string, "200")
        }), null)
        authenticate_cognito = optional(object({
          user_pool_arn = string
          user_pool_client_id = string
          user_pool_domain = string
          scope = optional(string, null)
          session_cookie_name = optional(string, null)
          session_timeout = optional(number, null)
          on_unauthenticated_request = optional(string, null)
        }), null)
        authenticate_oidc = optional(object({
          authorization_endpoint = string
          client_id = string
          client_secret = string
          issuer = string
          token_endpoint = string
          user_info_endpoint = string
          scope = optional(string, null)
          session_cookie_name = optional(string, null)
          session_timeout = optional(number, null)
          on_unauthenticated_request = optional(string, null)
        }), null)
      })
      # Additional listener rules
      rules = optional(list(object({
        priority = number
        conditions = list(object({
          field = string
          values = list(string)
          host_header = optional(object({
            values = list(string)
          }), null)
          path_pattern = optional(object({
            values = list(string)
          }), null)
          http_header = optional(object({
            http_header_name = string
            values = list(string)
          }), null)
          http_request_method = optional(object({
            values = list(string)
          }), null)
          query_string = optional(list(object({
            key = optional(string, null)
            value = string
          })), null)
          source_ip = optional(object({
            values = list(string)
          }), null)
        }))
        actions = list(object({
          type = string
          target_group_arn = optional(string, null)
          forward = optional(object({
            target_groups = list(object({
              arn = string
              weight = optional(number, 1)
            }))
            stickiness = optional(object({
              duration = number
              enabled = optional(bool, false)
            }), null)
          }), null)
          redirect = optional(object({
            path = optional(string, null)
            host = optional(string, null)
            port = optional(string, null)
            protocol = optional(string, null)
            query = optional(string, null)
            status_code = string
          }), null)
          fixed_response = optional(object({
            content_type = string
            message_body = optional(string, null)
            status_code = optional(string, "200")
          }), null)
          authenticate_cognito = optional(object({
            user_pool_arn = string
            user_pool_client_id = string
            user_pool_domain = string
            scope = optional(string, null)
            session_cookie_name = optional(string, null)
            session_timeout = optional(number, null)
            on_unauthenticated_request = optional(string, null)
          }), null)
          authenticate_oidc = optional(object({
            authorization_endpoint = string
            client_id = string
            client_secret = string
            issuer = string
            token_endpoint = string
            user_info_endpoint = string
            scope = optional(string, null)
            session_cookie_name = optional(string, null)
            session_timeout = optional(number, null)
            on_unauthenticated_request = optional(string, null)
          }), null)
        }))
      })), [])
      tags = optional(map(string), {})
    }))
    # WAF configuration
    enable_waf = optional(bool, false)
    waf_web_acl_arn = optional(string, null)
    # Shield configuration
    enable_shield = optional(bool, false)
    shield_protection_arn = optional(string, null)
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# RDS Variables
# ==============================================================================

variable "rds_instances" {
  description = "RDS database instances configuration"
  type = map(object({
    name = string
    engine = string
    engine_version = optional(string, null)
    instance_class = string
    allocated_storage = optional(number, 20)
    max_allocated_storage = optional(number, null)
    storage_type = optional(string, "gp2")
    storage_encrypted = optional(bool, true)
    db_name = string
    username = string
    password = string
    security_group_ids = list(string)
    backup_retention_period = optional(number, 7)
    backup_window = optional(string, "03:00-04:00")
    maintenance_window = optional(string, "sun:04:00-sun:05:00")
    multi_az = optional(bool, false)
    publicly_accessible = optional(bool, false)
    skip_final_snapshot = optional(bool, false)
    deletion_protection = optional(bool, false)
    # Enhanced RDS configuration options
    # Storage configuration
    storage_throughput = optional(number, null)
    storage_iops = optional(number, null)
    storage_autoscale = optional(bool, false)
    storage_autoscale_max = optional(number, null)
    storage_autoscale_min = optional(number, null)
    storage_autoscale_target = optional(number, null)
    # Performance Insights
    performance_insights_enabled = optional(bool, false)
    performance_insights_retention_period = optional(number, 7)
    performance_insights_kms_key_id = optional(string, null)
    # Monitoring
    monitoring_interval = optional(number, 0)
    monitoring_role_arn = optional(string, null)
    enable_cloudwatch_logs_exports = optional(list(string), [])
    # Network configuration
    port = optional(number, null)
    db_subnet_group_name = optional(string, null)
    parameter_group_name = optional(string, null)
    option_group_name = optional(string, null)
    # Security configuration
    kms_key_id = optional(string, null)
    copy_tags_to_snapshot = optional(bool, false)
    final_snapshot_identifier = optional(string, null)
    snapshot_identifier = optional(string, null)
    # Replication configuration
    replicate_source_db = optional(string, null)
    replicate_source_db_identifier = optional(string, null)
    replicate_source_db_arn = optional(string, null)
    replicate_source_db_region = optional(string, null)
    replicate_source_db_allocated_storage = optional(number, null)
    replicate_source_db_allow_major_version_upgrade = optional(bool, null)
    replicate_source_db_apply_immediately = optional(bool, null)
    replicate_source_db_auto_minor_version_upgrade = optional(bool, null)
    replicate_source_db_availability_zone = optional(string, null)
    replicate_source_db_backup_retention_period = optional(number, null)
    replicate_source_db_backup_window = optional(string, null)
    replicate_source_db_ca_cert_identifier = optional(string, null)
    replicate_source_db_character_set_name = optional(string, null)
    replicate_source_db_copy_tags_to_snapshot = optional(bool, null)
    replicate_source_db_db_name = optional(string, null)
    replicate_source_db_db_subnet_group_name = optional(string, null)
    replicate_source_db_deletion_protection = optional(bool, null)
    replicate_source_db_domain = optional(string, null)
    replicate_source_db_domain_iam_role_name = optional(string, null)
    replicate_source_db_enabled_cloudwatch_logs_exports = optional(list(string), null)
    replicate_source_db_engine_version = optional(string, null)
    replicate_source_db_final_snapshot_identifier = optional(string, null)
    replicate_source_db_iam_database_authentication_enabled = optional(bool, null)
    replicate_source_db_instance_class = optional(string, null)
    replicate_source_db_iops = optional(number, null)
    replicate_source_db_kms_key_id = optional(string, null)
    replicate_source_db_license_model = optional(string, null)
    replicate_source_db_maintenance_window = optional(string, null)
    replicate_source_db_max_allocated_storage = optional(number, null)
    replicate_source_db_monitoring_interval = optional(number, null)
    replicate_source_db_monitoring_role_arn = optional(string, null)
    replicate_source_db_multi_az = optional(bool, null)
    replicate_source_db_option_group_name = optional(string, null)
    replicate_source_db_parameter_group_name = optional(string, null)
    replicate_source_db_password = optional(string, null)
    replicate_source_db_performance_insights_enabled = optional(bool, null)
    replicate_source_db_performance_insights_kms_key_id = optional(string, null)
    replicate_source_db_performance_insights_retention_period = optional(number, null)
    replicate_source_db_port = optional(number, null)
    replicate_source_db_publicly_accessible = optional(bool, null)
    replicate_source_db_skip_final_snapshot = optional(bool, null)
    replicate_source_db_storage_encrypted = optional(bool, null)
    replicate_source_db_storage_type = optional(string, null)
    replicate_source_db_storage_throughput = optional(number, null)
    replicate_source_db_username = optional(string, null)
    replicate_source_db_vpc_security_group_ids = optional(list(string), null)
    # Timezone configuration
    timezone = optional(string, null)
    # Character set configuration
    character_set_name = optional(string, null)
    # License model
    license_model = optional(string, null)
    # Domain configuration
    domain = optional(string, null)
    domain_iam_role_name = optional(string, null)
    # IAM database authentication
    iam_database_authentication_enabled = optional(bool, false)
    # CA certificate identifier
    ca_cert_identifier = optional(string, null)
    # Allow major version upgrade
    allow_major_version_upgrade = optional(bool, false)
    # Auto minor version upgrade
    auto_minor_version_upgrade = optional(bool, true)
    # Apply immediately
    apply_immediately = optional(bool, false)
    # Availability zone
    availability_zone = optional(string, null)
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# ElastiCache Variables
# ==============================================================================

variable "elasticache_clusters" {
  description = "ElastiCache clusters configuration"
  type = map(object({
    name = string
    engine = string
    node_type = string
    num_cache_nodes = optional(number, 1)
    parameter_group_name = optional(string, null)
    port = optional(number, 6379)
    security_group_ids = list(string)
    preferred_availability_zones = optional(list(string), [])
    # Enhanced ElastiCache configuration options
    # Network configuration
    subnet_group_name = optional(string, null)
    availability_zone = optional(string, null)
    az_mode = optional(string, "single-az")
    # Security configuration
    at_rest_encryption_enabled = optional(bool, true)
    transit_encryption_enabled = optional(bool, false)
    transit_encryption_mode = optional(string, "preferred")
    auth_token = optional(string, null)
    auth_token_update_strategy = optional(string, "ROTATE")
    # Backup configuration
    snapshot_arns = optional(list(string), [])
    snapshot_name = optional(string, null)
    snapshot_window = optional(string, "00:00-01:00")
    snapshot_retention_limit = optional(number, 0)
    final_snapshot_identifier = optional(string, null)
    # Maintenance configuration
    maintenance_window = optional(string, "sun:05:00-sun:06:00")
    auto_minor_version_upgrade = optional(bool, true)
    # Logging configuration
    log_delivery_configuration = optional(list(object({
      destination = string
      destination_type = string
      log_format = string
      log_type = string
    })), [])
    # Notification configuration
    notification_topic_arn = optional(string, null)
    # Replication configuration
    replication_group_id = optional(string, null)
    replication_group_description = optional(string, null)
    replication_group_num_cache_clusters = optional(number, null)
    replication_group_automatic_failover_enabled = optional(bool, null)
    replication_group_multi_az_enabled = optional(bool, null)
    replication_group_node_type = optional(string, null)
    replication_group_port = optional(number, null)
    replication_group_parameter_group_name = optional(string, null)
    replication_group_subnet_group_name = optional(string, null)
    replication_group_security_group_ids = optional(list(string), null)
    replication_group_at_rest_encryption_enabled = optional(bool, null)
    replication_group_transit_encryption_enabled = optional(bool, null)
    replication_group_transit_encryption_mode = optional(string, null)
    replication_group_auth_token = optional(string, null)
    replication_group_snapshot_arns = optional(list(string), null)
    replication_group_snapshot_name = optional(string, null)
    replication_group_snapshot_window = optional(string, null)
    replication_group_snapshot_retention_limit = optional(number, null)
    replication_group_final_snapshot_identifier = optional(string, null)
    replication_group_maintenance_window = optional(string, null)
    replication_group_auto_minor_version_upgrade = optional(bool, null)
    replication_group_log_delivery_configuration = optional(list(object({
      destination = string
      destination_type = string
      log_format = string
      log_type = string
    })), null)
    replication_group_notification_topic_arn = optional(string, null)
    replication_group_preferred_cache_cluster_azs = optional(list(string), null)
    replication_group_num_node_groups = optional(number, null)
    replication_group_replicas_per_node_group = optional(number, null)
    replication_group_kms_key_id = optional(string, null)
    replication_group_user_group_ids = optional(list(string), null)
    replication_group_data_tiering_enabled = optional(bool, null)
    replication_group_global_replication_group_id = optional(string, null)
    replication_group_global_replication_group_member_role = optional(string, null)
    replication_group_global_replication_group_member_role_arn = optional(string, null)
    replication_group_global_replication_group_member_role_name = optional(string, null)
    replication_group_global_replication_group_member_role_path = optional(string, null)
    replication_group_global_replication_group_member_role_policy_arns = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_count = optional(number, null)
    replication_group_global_replication_group_member_role_policy_attachment_ids = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_names = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_policy_arns = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_roles = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_users = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_groups = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_arns = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_names = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_paths = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_versions = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_document = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_create_date = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_update_date = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_count = optional(number, null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_ids = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_names = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_policy_arns = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_roles = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_users = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_groups = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_arns = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_names = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_paths = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_versions = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_document = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_create_date = optional(list(string), null)
    replication_group_global_replication_group_member_role_policy_attachment_managed_policy_attachment_managed_policy_update_date = optional(list(string), null)
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Lambda Variables
# ==============================================================================

variable "lambda_functions" {
  description = "Lambda functions with VPC configuration"
  type = map(object({
    name = string
    filename = string
    handler = string
    runtime = string
    timeout = optional(number, 3)
    memory_size = optional(number, 128)
    subnet_ids = list(string)
    security_group_ids = list(string)
    environment_variables = optional(map(string), {})
    # Enhanced Lambda configuration options
    # Function configuration
    description = optional(string, null)
    reserved_concurrent_executions = optional(number, -1)
    publish = optional(bool, false)
    version_description = optional(string, null)
    # Code configuration
    source_code_hash = optional(string, null)
    s3_bucket = optional(string, null)
    s3_key = optional(string, null)
    s3_object_version = optional(string, null)
    image_uri = optional(string, null)
    image_config = optional(object({
      entry_point = optional(list(string), null)
      command = optional(list(string), null)
      working_directory = optional(string, null)
    }), null)
    # Environment configuration
    environment = optional(object({
      variables = optional(map(string), {})
    }), null)
    # VPC configuration
    vpc_config = optional(object({
      subnet_ids = list(string)
      security_group_ids = list(string)
    }), null)
    # File system configuration
    file_system_config = optional(object({
      arn = string
      local_mount_path = string
    }), null)
    # Dead letter configuration
    dead_letter_config = optional(object({
      target_arn = string
    }), null)
    # Tracing configuration
    tracing_config = optional(object({
      mode = string
    }), null)
    # KMS configuration
    kms_key_arn = optional(string, null)
    # Layers configuration
    layers = optional(list(string), [])
    # Runtime management configuration
    runtime_management_config = optional(object({
      update_runtime_on = string
      runtime_version_arn = optional(string, null)
    }), null)
    # Snap start configuration
    snap_start = optional(object({
      apply_on = string
    }), null)
    # Ephemeral storage configuration
    ephemeral_storage = optional(object({
      size = number
    }), null)
    # Function URL configuration
    function_url = optional(object({
      authorization_type = optional(string, "NONE")
      cors = optional(object({
        allow_credentials = optional(bool, false)
        allow_headers = optional(list(string), [])
        allow_methods = optional(list(string), [])
        allow_origins = optional(list(string), [])
        expose_headers = optional(list(string), [])
        max_age = optional(number, null)
      }), null)
      invoke_mode = optional(string, "BUFFERED")
    }), null)
    # Event source mappings
    event_source_mappings = optional(list(object({
      event_source_arn = string
      function_name = string
      starting_position = optional(string, "LATEST")
      starting_position_timestamp = optional(string, null)
      batch_size = optional(number, 100)
      maximum_batching_window_in_seconds = optional(number, 0)
      parallelization_factor = optional(number, 1)
      maximum_retry_attempts = optional(number, -1)
      maximum_record_age_in_seconds = optional(number, -1)
      bisect_batch_on_function_error = optional(bool, false)
      function_response_types = optional(list(string), [])
      tumbling_window_in_seconds = optional(number, 0)
      topics = optional(list(string), [])
      queues = optional(list(string), [])
      streams = optional(list(string), [])
      enabled = optional(bool, true)
      filter_criteria = optional(object({
        filters = optional(list(object({
          pattern = string
        })), [])
      }), null)
      scaling_config = optional(object({
        maximum_concurrency = optional(number, null)
      }), null)
      destination_config = optional(object({
        on_failure = optional(object({
          destination_arn = string
        }), null)
        on_success = optional(object({
          destination_arn = string
        }), null)
      }), null)
      self_managed_event_source = optional(object({
        endpoints = map(string)
      }), null)
      source_access_configurations = optional(list(object({
        type = string
        uri = string
      })), [])
    })), [])
    # Alias configuration
    aliases = optional(list(object({
      name = string
      function_name = string
      function_version = string
      description = optional(string, null)
      routing_config = optional(object({
        additional_version_weights = optional(map(number), {})
        additional_version_weights_override = optional(map(number), {})
      }), null)
    })), [])
    # Provisioned concurrency configuration
    provisioned_concurrency_configs = optional(list(object({
      function_name = string
      qualifier = string
      provisioned_concurrent_executions = number
    })), [])
    # Code signing configuration
    code_signing_config = optional(object({
      allowed_publishers = object({
        signing_profile_version_arns = list(string)
      })
      code_signing_policies = optional(object({
        untrusted_artifact_on_deployment = string
      }), null)
      description = optional(string, null)
    }), null)
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# EKS Variables
# ==============================================================================

variable "eks_config" {
  description = "EKS cluster configuration"
  type = object({
    cluster_version = optional(string, "1.28")
    cluster_endpoint_private_access = optional(bool, true)
    cluster_endpoint_public_access  = optional(bool, true)
    cluster_endpoint_public_access_cidrs = optional(list(string), ["0.0.0.0/0"])
    cluster_service_ipv4_cidr = optional(string, "172.16.0.0/12")
    cluster_ip_family = optional(string, "ipv4")
    enable_irsa = optional(bool, true)
    enable_cluster_creator_admin_permissions = optional(bool, true)
    create_cloudwatch_log_group = optional(bool, true)
    cluster_log_retention_in_days = optional(number, 7)
    cluster_log_types = optional(list(string), ["api", "audit", "authenticator", "controllerManager", "scheduler"])
    # Enhanced EKS configuration options
    # Cluster configuration
    cluster_name = optional(string, null)
    cluster_role_name = optional(string, null)
    cluster_role_use_name_prefix = optional(bool, true)
    cluster_role_permissions_boundary_arn = optional(string, null)
    cluster_role_additional_policies = optional(map(string), {})
    cluster_role_tags = optional(map(string), {})
    # Network configuration
    cluster_endpoint_private_access_vpc_config = optional(object({
      endpoint_id = optional(string, null)
      subnet_ids = optional(list(string), [])
      security_group_ids = optional(list(string), [])
    }), null)
    cluster_endpoint_public_access_vpc_config = optional(object({
      endpoint_id = optional(string, null)
      subnet_ids = optional(list(string), [])
      security_group_ids = optional(list(string), [])
    }), null)
    # Security configuration
    cluster_security_group_id = optional(string, null)
    cluster_security_group_name = optional(string, null)
    cluster_security_group_use_name_prefix = optional(bool, true)
    cluster_security_group_description = optional(string, "EKS cluster security group")
    cluster_security_group_additional_rules = optional(map(object({
      description = string
      protocol = string
      from_port = number
      to_port = number
      type = string
      cidr_blocks = optional(list(string), null)
      ipv6_cidr_blocks = optional(list(string), null)
      prefix_list_ids = optional(list(string), null)
      security_groups = optional(list(string), null)
      self = optional(bool, null)
      source_security_group_id = optional(string, null)
      source_security_group_owner_id = optional(string, null)
    })), {})
    cluster_security_group_tags = optional(map(string), {})
    # Node security group configuration
    node_security_group_id = optional(string, null)
    node_security_group_name = optional(string, null)
    node_security_group_use_name_prefix = optional(bool, true)
    node_security_group_description = optional(string, "EKS node security group")
    node_security_group_additional_rules = optional(map(object({
      description = string
      protocol = string
      from_port = number
      to_port = number
      type = string
      cidr_blocks = optional(list(string), null)
      ipv6_cidr_blocks = optional(list(string), null)
      prefix_list_ids = optional(list(string), null)
      security_groups = optional(list(string), null)
      self = optional(bool, null)
      source_security_group_id = optional(string, null)
      source_security_group_owner_id = optional(string, null)
    })), {})
    node_security_group_tags = optional(map(string), {})
    # Addon configuration
    cluster_addons = optional(map(object({
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    })), {})
    # Identity provider configuration
    cluster_identity_providers = optional(map(object({
      client_id = string
      groups_claim = optional(string, null)
      groups_prefix = optional(string, null)
      issuer_url = string
      required_claims = optional(map(string), {})
      username_claim = optional(string, null)
      username_prefix = optional(string, null)
    })), {})
    # Access entries configuration
    cluster_access_entries = optional(map(object({
      kubernetes_groups = optional(list(string), [])
      principal_arn = string
      type = optional(string, "STANDARD")
      user_name = optional(string, null)
    })), {})
    # KMS configuration
    cluster_encryption_config = optional(object({
      provider_key_arn = string
      resources = list(string)
    }), null)
    # Outpost configuration
    cluster_outpost_config = optional(object({
      control_plane_instance_type = string
      outpost_arns = list(string)
    }), null)
    # VPC CNI configuration
    cluster_vpc_cni_config = optional(object({
      addon_name = optional(string, "vpc-cni")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # CoreDNS configuration
    cluster_coredns_config = optional(object({
      addon_name = optional(string, "coredns")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # Kube-proxy configuration
    cluster_kube_proxy_config = optional(object({
      addon_name = optional(string, "kube-proxy")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # AWS Load Balancer Controller configuration
    cluster_aws_load_balancer_controller_config = optional(object({
      addon_name = optional(string, "aws-load-balancer-controller")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # EBS CSI Driver configuration
    cluster_ebs_csi_driver_config = optional(object({
      addon_name = optional(string, "aws-ebs-csi-driver")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # EFS CSI Driver configuration
    cluster_efs_csi_driver_config = optional(object({
      addon_name = optional(string, "aws-efs-csi-driver")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # AWS Distro for OpenTelemetry configuration
    cluster_adot_config = optional(object({
      addon_name = optional(string, "adot")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # Amazon Managed Service for Prometheus configuration
    cluster_amp_config = optional(object({
      addon_name = optional(string, "amazon-managed-service-prometheus")
      addon_version = optional(string, null)
      service_account_role_arn = optional(string, null)
      resolve_conflicts = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      preserve = optional(bool, false)
      most_recent = optional(bool, true)
      before_compute = optional(bool, false)
      configuration_values = optional(string, null)
      timeouts = optional(object({
        create = optional(string, null)
        update = optional(string, null)
        delete = optional(string, null)
      }), null)
    }), null)
    # Tags
    tags = optional(map(string), {})
  })
  default = {}
}

variable "eks_node_groups" {
  description = "EKS node groups configuration"
  type = map(object({
    name = string
    instance_types = list(string)
    capacity_type = optional(string, "ON_DEMAND")
    disk_size = optional(number, 20)
    disk_type = optional(string, "gp3")
    ami_type = optional(string, "AL2_x86_64")
    platform = optional(string, "linux")
    desired_size = optional(number, 2)
    max_size = optional(number, 5)
    min_size = optional(number, 1)
    max_unavailable = optional(number, 1)
    max_unavailable_percentage = optional(number, null)
    force_update_version = optional(bool, false)
    update_config = optional(object({
      max_unavailable_percentage = optional(number, 33)
    }), {})
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
    # Enhanced EKS node group configuration options
    # Node group configuration
    node_group_name = optional(string, null)
    node_group_use_name_prefix = optional(bool, true)
    node_group_role_name = optional(string, null)
    node_group_role_use_name_prefix = optional(bool, true)
    node_group_role_permissions_boundary_arn = optional(string, null)
    node_group_role_additional_policies = optional(map(string), {})
    node_group_role_tags = optional(map(string), {})
    # Launch template configuration
    create_launch_template = optional(bool, false)
    launch_template_name = optional(string, null)
    launch_template_use_name_prefix = optional(bool, true)
    launch_template_version = optional(string, null)
    launch_template_id = optional(string, null)
    launch_template_tags = optional(map(string), {})
    # Launch template configuration
    launch_template_config = optional(object({
      id = optional(string, null)
      name = optional(string, null)
      version = optional(string, null)
    }), null)
    # Instance configuration
    instance_type = optional(string, null)
    instance_types = optional(list(string), [])
    capacity_type = optional(string, "ON_DEMAND")
    # Storage configuration
    disk_size = optional(number, 20)
    disk_type = optional(string, "gp3")
    disk_throughput = optional(number, null)
    disk_iops = optional(number, null)
    disk_encrypted = optional(bool, true)
    disk_kms_key_id = optional(string, null)
    disk_delete_on_termination = optional(bool, true)
    # AMI configuration
    ami_type = optional(string, "AL2_x86_64")
    ami_release_version = optional(string, null)
    ami_launch_template_id = optional(string, null)
    ami_launch_template_name = optional(string, null)
    ami_launch_template_version = optional(string, null)
    # Platform configuration
    platform = optional(string, "linux")
    # Scaling configuration
    desired_size = optional(number, 2)
    max_size = optional(number, 5)
    min_size = optional(number, 1)
    # Update configuration
    max_unavailable = optional(number, 1)
    max_unavailable_percentage = optional(number, null)
    max_surge = optional(number, null)
    max_surge_percentage = optional(number, null)
    force_update_version = optional(bool, false)
    update_config = optional(object({
      max_unavailable_percentage = optional(number, 33)
      max_surge_percentage = optional(number, null)
    }), {})
    # Network configuration
    subnet_ids = optional(list(string), [])
    remote_access = optional(object({
      ec2_ssh_key = optional(string, null)
      source_security_group_ids = optional(list(string), [])
    }), null)
    # Security configuration
    vpc_security_group_ids = optional(list(string), [])
    # User data configuration
    user_data_template_path = optional(string, null)
    user_data_template_vars = optional(map(string), {})
    # Block device mappings
    block_device_mappings = optional(list(object({
      device_name = string
      ebs = optional(object({
        delete_on_termination = optional(bool, true)
        encrypted = optional(bool, true)
        iops = optional(number, null)
        kms_key_id = optional(string, null)
        snapshot_id = optional(string, null)
        throughput = optional(number, null)
        volume_size = optional(number, 20)
        volume_type = optional(string, "gp3")
      }), null)
      no_device = optional(bool, null)
      virtual_name = optional(string, null)
    })), [])
    # Metadata options
    metadata_options = optional(object({
      http_endpoint = optional(string, "enabled")
      http_put_response_hop_limit = optional(number, 2)
      http_tokens = optional(string, "required")
      instance_metadata_tags = optional(string, "disabled")
    }), null)
    # Monitoring configuration
    detailed_monitoring = optional(bool, false)
    # Placement configuration
    placement = optional(object({
      group_name = optional(string, null)
      tenancy = optional(string, "default")
      partition_number = optional(number, null)
      spread_domain = optional(string, null)
      host_id = optional(string, null)
      affinity = optional(string, null)
      availability_zone = optional(string, null)
    }), null)
    # Hibernation configuration
    hibernation = optional(object({
      configured = bool
    }), null)
    # Credit specification
    credit_specification = optional(object({
      cpu_credits = optional(string, null)
    }), null)
    # CPU options
    cpu_options = optional(object({
      core_count = optional(number, null)
      threads_per_core = optional(number, null)
      amd_sev_snp = optional(string, null)
    }), null)
    # Enclave options
    enclave_options = optional(object({
      enabled = optional(bool, null)
    }), null)
    # Instance market options
    instance_market_options = optional(object({
      market_type = optional(string, null)
      spot_options = optional(object({
        block_duration_minutes = optional(number, null)
        instance_interruption_behavior = optional(string, null)
        max_price = optional(string, null)
        spot_instance_type = optional(string, null)
        valid_until = optional(string, null)
      }), null)
    }), null)
    # License specifications
    license_specifications = optional(list(object({
      license_configuration_arn = string
    })), [])
    # Maintenance options
    maintenance_options = optional(object({
      auto_recovery = optional(string, null)
    }), null)
    # Private DNS name options
    private_dns_name_options = optional(object({
      enable_resource_name_dns_a_record = optional(bool, null)
      enable_resource_name_dns_aaaa_record = optional(bool, null)
      hostname_type = optional(string, null)
    }), null)
    # Root block device configuration
    root_block_device = optional(list(object({
      delete_on_termination = optional(bool, true)
      encrypted = optional(bool, true)
      iops = optional(number, null)
      kms_key_id = optional(string, null)
      throughput = optional(number, null)
      volume_size = optional(number, 20)
      volume_type = optional(string, "gp3")
    })), [])
    # Secondary private IPs
    secondary_private_ips = optional(list(string), [])
    # Security groups
    vpc_security_group_ids = optional(list(string), [])
    # Source destination check
    source_dest_check = optional(bool, null)
    # Tags
    tags = optional(map(string), {})
    # Labels and taints
    labels = optional(map(string), {})
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })), [])
  }))
  default = {}
}

variable "eks_fargate_profiles" {
  description = "EKS Fargate profiles configuration"
  type = map(object({
    name = string
    selectors = list(object({
      namespace = string
      labels = optional(map(string), {})
    }))
    subnets = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# ECR Variables
# ==============================================================================

variable "ecr_repositories" {
  description = "ECR repositories configuration"
  type = map(object({
    name = string
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push = optional(bool, true)
    encryption_type = optional(string, "AES256")
    kms_key_id = optional(string, null)
    lifecycle_policy = optional(object({
      max_image_count = optional(number, 30)
      max_age_days = optional(number, 90)
    }), {})
    # Enhanced ECR configuration options
    # Repository configuration
    repository_name = optional(string, null)
    force_delete = optional(bool, false)
    # Image scanning configuration
    image_scanning_configuration = optional(object({
      scan_on_push = bool
    }), null)
    # Encryption configuration
    encryption_configuration = optional(object({
      encryption_type = string
      kms_key = optional(string, null)
    }), null)
    # Lifecycle policy configuration
    lifecycle_policy_config = optional(object({
      policy = string
    }), null)
    # Repository policy configuration
    repository_policy = optional(object({
      policy = string
    }), null)
    # Registry scanning configuration
    registry_scanning_configuration = optional(object({
      scan_type = string
      rules = optional(list(object({
        repository_filters = list(object({
          filter = string
          filter_type = string
        }))
        scan_frequency = string
      })), [])
    }), null)
    # Pull through cache configuration
    pull_through_cache_rules = optional(list(object({
      ecr_repository_prefix = string
      upstream_registry_url = string
      registry_id = optional(string, null)
    })), [])
    # Replication configuration
    replication_configuration = optional(object({
      replication_rules = list(object({
        destinations = list(object({
          region = string
          registry_id = optional(string, null)
        }))
        repository_filters = optional(list(object({
          filter = string
          filter_type = string
        })), [])
      }))
    }), null)
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Security Groups Variables
# ==============================================================================

variable "security_groups" {
  description = "Security groups configuration"
  type = map(object({
    name = string
    description = string
    vpc_id = optional(string, null)
    ingress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), [])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
    })), [])
    egress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
    })), [])
    # Enhanced security group configuration options
    # Security group configuration
    security_group_name = optional(string, null)
    security_group_use_name_prefix = optional(bool, true)
    security_group_description = optional(string, null)
    # VPC configuration
    vpc_id = optional(string, null)
    # Ingress rules configuration
    ingress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), [])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids = optional(list(string), [])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
      source_security_group_id = optional(string, null)
      source_security_group_owner_id = optional(string, null)
      # Enhanced ingress options
      type = optional(string, "ingress")
      rule_no = optional(number, null)
      icmp_type = optional(number, null)
      icmp_code = optional(number, null)
      icmpv6_type = optional(number, null)
      icmpv6_code = optional(number, null)
      # Referenced security group options
      referenced_security_group_id = optional(string, null)
      referenced_security_group_owner_id = optional(string, null)
      referenced_security_group_rule_id = optional(string, null)
      # Description options
      description_override = optional(string, null)
      # Timeouts
      timeouts = optional(object({
        create = optional(string, null)
        delete = optional(string, null)
      }), null)
    })), [])
    # Egress rules configuration
    egress_rules = optional(list(object({
      description = optional(string, "")
      from_port = number
      to_port = number
      protocol = string
      cidr_blocks = optional(list(string), ["0.0.0.0/0"])
      ipv6_cidr_blocks = optional(list(string), [])
      prefix_list_ids = optional(list(string), [])
      security_groups = optional(list(string), [])
      self = optional(bool, false)
      source_security_group_id = optional(string, null)
      source_security_group_owner_id = optional(string, null)
      # Enhanced egress options
      type = optional(string, "egress")
      rule_no = optional(number, null)
      icmp_type = optional(number, null)
      icmp_code = optional(number, null)
      icmpv6_type = optional(number, null)
      icmpv6_code = optional(number, null)
      # Referenced security group options
      referenced_security_group_id = optional(string, null)
      referenced_security_group_owner_id = optional(string, null)
      referenced_security_group_rule_id = optional(string, null)
      # Description options
      description_override = optional(string, null)
      # Timeouts
      timeouts = optional(object({
        create = optional(string, null)
        delete = optional(string, null)
      }), null)
    })), [])
    # Security group rules configuration
    security_group_rules = optional(map(object({
      type = string
      from_port = optional(number, null)
      to_port = optional(number, null)
      protocol = optional(string, "-1")
      description = optional(string, null)
      cidr_blocks = optional(list(string), null)
      ipv6_cidr_blocks = optional(list(string), null)
      prefix_list_ids = optional(list(string), null)
      security_groups = optional(list(string), null)
      self = optional(bool, null)
      source_security_group_id = optional(string, null)
      source_security_group_owner_id = optional(string, null)
      # Enhanced rule options
      rule_no = optional(number, null)
      icmp_type = optional(number, null)
      icmp_code = optional(number, null)
      icmpv6_type = optional(number, null)
      icmpv6_code = optional(number, null)
      # Referenced security group options
      referenced_security_group_id = optional(string, null)
      referenced_security_group_owner_id = optional(string, null)
      referenced_security_group_rule_id = optional(string, null)
      # Description options
      description_override = optional(string, null)
      # Timeouts
      timeouts = optional(object({
        create = optional(string, null)
        delete = optional(string, null)
      }), null)
    })), {})
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Monitoring and Logging Variables
# ==============================================================================

variable "enable_cloudwatch_container_insights" {
  description = "Enable CloudWatch Container Insights for EKS"
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller"
  type        = bool
  default     = true
}

variable "enable_metrics_server" {
  description = "Enable Metrics Server"
  type        = bool
  default     = true
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler"
  type        = bool
  default     = false
}

# ==============================================================================
# Backup and Disaster Recovery Variables
# ==============================================================================

variable "enable_velero_backup" {
  description = "Enable Velero backup solution"
  type        = bool
  default     = false
}

variable "velero_backup_config" {
  description = "Velero backup configuration"
  type = object({
    backup_location_bucket = optional(string, "")
    backup_location_region = optional(string, "")
    schedule = optional(string, "0 2 * * *") # Daily at 2 AM
    retention_days = optional(number, 30)
  })
  default = {}
}

# ==============================================================================
# Network Policy Variables
# ==============================================================================

variable "enable_network_policies" {
  description = "Enable network policies for EKS"
  type        = bool
  default     = false
}

variable "network_policy_provider" {
  description = "Network policy provider (calico, cilium, or aws-vpc-cni)"
  type        = string
  default     = "calico"
  validation {
    condition     = contains(["calico", "cilium", "aws-vpc-cni"], var.network_policy_provider)
    error_message = "Network policy provider must be one of: calico, cilium, aws-vpc-cni."
  }
}

# ==============================================================================
# Additional AWS Services Variables
# ==============================================================================

variable "s3_buckets" {
  description = "S3 buckets configuration"
  type = map(object({
    name = string
    acl = optional(string, "private")
    versioning = optional(object({
      enabled = optional(bool, false)
      mfa_delete = optional(bool, false)
    }), {})
    server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm = string
          kms_master_key_id = optional(string, null)
        })
        bucket_key_enabled = optional(bool, false)
      })
    }), null)
    lifecycle_configuration = optional(list(object({
      id = optional(string, null)
      status = string
      filter = optional(object({
        prefix = optional(string, null)
        tags = optional(map(string), {})
      }), null)
      expiration = optional(object({
        days = optional(number, null)
        date = optional(string, null)
        expired_object_delete_marker = optional(bool, null)
      }), null)
      noncurrent_version_expiration = optional(object({
        noncurrent_days = number
      }), null)
      abort_incomplete_multipart_upload = optional(object({
        days_after_initiation = number
      }), null)
    })), [])
    cors_configuration = optional(list(object({
      allowed_headers = optional(list(string), [])
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers = optional(list(string), [])
      max_age_seconds = optional(number, null)
    })), [])
    website_configuration = optional(object({
      index_document = optional(string, null)
      error_document = optional(string, null)
      redirect_all_requests_to = optional(string, null)
      routing_rules = optional(string, null)
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudwatch_log_groups" {
  description = "CloudWatch log groups configuration"
  type = map(object({
    name = string
    retention_in_days = optional(number, 7)
    kms_key_id = optional(string, null)
    skip_destroy = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cloudwatch_alarms" {
  description = "CloudWatch alarms configuration"
  type = map(object({
    name = string
    comparison_operator = string
    evaluation_periods = number
    metric_name = string
    namespace = string
    period = number
    statistic = string
    threshold = number
    alarm_description = optional(string, null)
    alarm_actions = optional(list(string), [])
    ok_actions = optional(list(string), [])
    insufficient_data_actions = optional(list(string), [])
    dimensions = optional(map(string), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sns_topics" {
  description = "SNS topics configuration"
  type = map(object({
    name = string
    display_name = optional(string, null)
    policy = optional(string, null)
    delivery_policy = optional(string, null)
    kms_master_key_id = optional(string, null)
    fifo_topic = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sqs_queues" {
  description = "SQS queues configuration"
  type = map(object({
    name = string
    delay_seconds = optional(number, 0)
    max_message_size = optional(number, 262144)
    message_retention_seconds = optional(number, 345600)
    receive_wait_time_seconds = optional(number, 0)
    redrive_policy = optional(string, null)
    redrive_allow_policy = optional(string, null)
    policy = optional(string, null)
    visibility_timeout_seconds = optional(number, 30)
    fifo_queue = optional(bool, false)
    content_based_deduplication = optional(bool, false)
    deduplication_scope = optional(string, null)
    fifo_throughput_limit = optional(string, null)
    kms_master_key_id = optional(string, null)
    kms_data_key_reuse_period_seconds = optional(number, 300)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "kms_keys" {
  description = "KMS keys configuration"
  type = map(object({
    description = string
    key_usage = optional(string, "ENCRYPT_DECRYPT")
    customer_master_key_spec = optional(string, "SYMMETRIC_DEFAULT")
    policy = optional(string, null)
    bypass_policy_lockout_safety_check = optional(bool, false)
    deletion_window_in_days = optional(number, 7)
    is_enabled = optional(bool, true)
    enable_key_rotation = optional(bool, true)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_roles" {
  description = "IAM roles configuration"
  type = map(object({
    name = string
    assume_role_policy = string
    description = optional(string, null)
    force_detach_policies = optional(bool, false)
    max_session_duration = optional(number, 3600)
    path = optional(string, "/")
    permissions_boundary = optional(string, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_policies" {
  description = "IAM policies configuration"
  type = map(object({
    name = string
    description = optional(string, null)
    path = optional(string, "/")
    policy = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "iam_users" {
  description = "IAM users configuration"
  type = map(object({
    name = string
    path = optional(string, "/")
    permissions_boundary = optional(string, null)
    force_destroy = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "route53_zones" {
  description = "Route53 hosted zones configuration"
  type = map(object({
    name = string
    comment = optional(string, null)
    force_destroy = optional(bool, false)
    private_zone = optional(bool, false)
    vpc = optional(object({
      vpc_id = string
      vpc_region = optional(string, null)
    }), null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "route53_records" {
  description = "Route53 records configuration"
  type = map(object({
    zone_id = string
    name = string
    type = string
    ttl = optional(number, null)
    records = optional(list(string), [])
    set_identifier = optional(string, null)
    health_check_id = optional(string, null)
    alias = optional(object({
      name = string
      zone_id = string
      evaluate_target_health = optional(bool, false)
    }), null)
    weighted_routing_policy = optional(object({
      weight = number
    }), null)
    failover_routing_policy = optional(object({
      type = string
    }), null)
    latency_routing_policy = optional(object({
      region = string
    }), null)
    geolocation_routing_policy = optional(object({
      continent = optional(string, null)
      country = optional(string, null)
      subdivision = optional(string, null)
    }), null)
    multivalue_answer_routing_policy = optional(bool, null)
    allow_overwrite = optional(bool, false)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "waf_web_acls" {
  description = "WAF web ACLs configuration"
  type = map(object({
    name = string
    description = optional(string, null)
    scope = string
    default_action = object({
      allow = optional(object({}), null)
      block = optional(object({}), null)
    })
    rules = optional(list(object({
      name = string
      priority = number
      action = optional(object({
        allow = optional(object({}), null)
        block = optional(object({}), null)
        count = optional(object({}), null)
      }), null)
      override_action = optional(object({
        none = optional(object({}), null)
        count = optional(object({}), null)
      }), null)
      statement = object({
        managed_rule_group_statement = optional(object({
          name = string
          vendor_name = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), null)
        rate_based_statement = optional(object({
          limit = number
          aggregate_key_type = optional(string, "IP")
        }), null)
        geo_match_statement = optional(object({
          country_codes = list(string)
          forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
          }), null)
        }), null)
        ip_set_reference_statement = optional(object({
          arn = string
          ip_set_forwarded_ip_config = optional(object({
            header_name = string
            fallback_behavior = string
            position = string
          }), null)
        }), null)
        regex_pattern_set_reference_statement = optional(object({
          arn = string
          field_to_match = object({
            single_header = optional(object({
              name = string
            }), null)
            single_query_argument = optional(object({
              name = string
            }), null)
            all_query_parameters = optional(object({}), null)
            uri_path = optional(object({}), null)
            query_string = optional(object({}), null)
            body = optional(object({
              oversize_handling = optional(string, null)
            }), null)
            method = optional(object({}), null)
          })
          text_transformation = object({
            priority = number
            type = string
          })
        }), null)
        rule_group_reference_statement = optional(object({
          arn = string
          excluded_rule = optional(list(object({
            name = string
          })), [])
        }), null)
        and_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
            }), null)
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), null)
            }), null)
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), null)
            }), null)
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), null)
                single_query_argument = optional(object({
                  name = string
                }), null)
                all_query_parameters = optional(object({}), null)
                uri_path = optional(object({}), null)
                query_string = optional(object({}), null)
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), null)
                method = optional(object({}), null)
              })
              text_transformation = object({
                priority = number
                type = string
              })
            }), null)
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
          }))
        }), null)
        or_statement = optional(object({
          statement = list(object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
            }), null)
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), null)
            }), null)
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), null)
            }), null)
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), null)
                single_query_argument = optional(object({
                  name = string
                }), null)
                all_query_parameters = optional(object({}), null)
                uri_path = optional(object({}), null)
                query_string = optional(object({}), null)
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), null)
                method = optional(object({}), null)
              })
              text_transformation = object({
                priority = number
                type = string
              })
            }), null)
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
          }))
        }), null)
        not_statement = optional(object({
          statement = object({
            managed_rule_group_statement = optional(object({
              name = string
              vendor_name = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
            rate_based_statement = optional(object({
              limit = number
              aggregate_key_type = optional(string, "IP")
            }), null)
            geo_match_statement = optional(object({
              country_codes = list(string)
              forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
              }), null)
            }), null)
            ip_set_reference_statement = optional(object({
              arn = string
              ip_set_forwarded_ip_config = optional(object({
                header_name = string
                fallback_behavior = string
                position = string
              }), null)
            }), null)
            regex_pattern_set_reference_statement = optional(object({
              arn = string
              field_to_match = object({
                single_header = optional(object({
                  name = string
                }), null)
                single_query_argument = optional(object({
                  name = string
                }), null)
                all_query_parameters = optional(object({}), null)
                uri_path = optional(object({}), null)
                query_string = optional(object({}), null)
                body = optional(object({
                  oversize_handling = optional(string, null)
                }), null)
                method = optional(object({}), null)
              })
              text_transformation = object({
                priority = number
                type = string
              })
            }), null)
            rule_group_reference_statement = optional(object({
              arn = string
              excluded_rule = optional(list(object({
                name = string
              })), [])
            }), null)
          })
        }), null)
      })
      visibility_config = object({
        cloudwatch_metrics_enabled = bool
        metric_name = string
        sampled_requests_enabled = bool
      })
    })), [])
    visibility_config = object({
      cloudwatch_metrics_enabled = bool
      metric_name = string
      sampled_requests_enabled = bool
    })
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced EC2 Instance Configuration Variables
# ==============================================================================

variable "ec2_instances" {
  description = "Map of EC2 instances to create"
  type = map(object({
    # Basic configuration
    name = string
    ami = optional(string, null)
    ami_owner = optional(string, null)
    ami_filter_name = optional(string, null)
    ami_filter_values = optional(list(string), [])
    instance_type = optional(string, "t3.micro")
    availability_zone = optional(string, null)
    subnet_id = optional(string, null)
    vpc_security_group_ids = optional(list(string), [])
    
    # Key pair and SSH
    key_name = optional(string, null)
    get_password_data = optional(bool, false)
    
    # IAM configuration
    iam_instance_profile = optional(string, null)
    create_iam_instance_profile = optional(bool, false)
    iam_role_name = optional(string, null)
    iam_role_description = optional(string, null)
    iam_role_path = optional(string, "/")
    iam_role_permissions_boundary = optional(string, null)
    iam_role_policies = optional(map(string), {})
    iam_role_managed_policy_arns = optional(list(string), [])
    
    # Storage configuration
    root_block_device = optional(list(object({
      volume_type = optional(string, "gp3")
      volume_size = optional(number, 8)
      volume_size_gb = optional(number, null)
      iops = optional(number, null)
      throughput = optional(number, null)
      encrypted = optional(bool, true)
      kms_key_id = optional(string, null)
      delete_on_termination = optional(bool, true)
      snapshot_id = optional(string, null)
      device_name = optional(string, "/dev/xvda")
      tags = optional(map(string), {})
    })), [])
    
    ebs_block_device = optional(list(object({
      device_name = string
      volume_type = optional(string, "gp3")
      volume_size = optional(number, 8)
      volume_size_gb = optional(number, null)
      iops = optional(number, null)
      throughput = optional(number, null)
      encrypted = optional(bool, true)
      kms_key_id = optional(string, null)
      delete_on_termination = optional(bool, true)
      snapshot_id = optional(string, null)
      tags = optional(map(string), {})
    })), [])
    
    ephemeral_block_device = optional(list(object({
      device_name = string
      virtual_name = string
      no_device = optional(bool, null)
    })), [])
    
    # Network configuration
    associate_public_ip_address = optional(bool, false)
    private_ip = optional(string, null)
    secondary_private_ips = optional(list(string), [])
    source_dest_check = optional(bool, true)
    
    # Network interfaces
    network_interface = optional(list(object({
      device_index = number
      network_interface_id = optional(string, null)
      delete_on_termination = optional(bool, true)
      network_card_index = optional(number, 0)
      interface_type = optional(string, null)
      ipv4_prefix_count = optional(number, null)
      ipv4_prefixes = optional(list(string), [])
      ipv6_address_count = optional(number, null)
      ipv6_addresses = optional(list(string), [])
      ipv6_prefix_count = optional(number, null)
      ipv6_prefixes = optional(list(string), [])
      private_ip_address = optional(string, null)
      private_ip_list = optional(list(string), [])
      private_ip_list_enabled = optional(bool, false)
      security_groups = optional(list(string), [])
      subnet_id = optional(string, null)
      associate_carrier_ip_address = optional(bool, null)
      associate_public_ip_address = optional(bool, null)
      delete_on_termination = optional(bool, null)
      description = optional(string, null)
      ipv4_prefix_count = optional(number, null)
      ipv4_prefixes = optional(list(string), [])
      ipv6_address_count = optional(number, null)
      ipv6_addresses = optional(list(string), [])
      ipv6_prefix_count = optional(number, null)
      ipv6_prefixes = optional(list(string), [])
      private_ip_address = optional(string, null)
      private_ip_list = optional(list(string), [])
      private_ip_list_enabled = optional(bool, false)
      security_groups = optional(list(string), [])
      subnet_id = optional(string, null)
    })), [])
    
    # User data and metadata
    user_data = optional(string, null)
    user_data_base64 = optional(string, null)
    user_data_replace_on_change = optional(bool, false)
    metadata_options = optional(object({
      http_endpoint = optional(string, "enabled")
      http_tokens = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      http_protocol_ipv6 = optional(string, "disabled")
      instance_metadata_tags = optional(string, "disabled")
    }), {})
    
    # Monitoring and maintenance
    monitoring = optional(bool, false)
    disable_api_termination = optional(bool, false)
    instance_initiated_shutdown_behavior = optional(string, "stop")
    
    # Placement configuration
    placement_group = optional(string, null)
    placement_partition_number = optional(number, null)
    tenancy = optional(string, "default")
    host_id = optional(string, null)
    host_resource_group_arn = optional(string, null)
    affinity = optional(string, null)
    
    # Capacity reservation
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string, null)
      capacity_reservation_target = optional(object({
        capacity_reservation_id = optional(string, null)
        capacity_reservation_resource_group_arn = optional(string, null)
      }), {})
    }), {})
    
    # Hibernation
    hibernation = optional(bool, false)
    
    # Credit specification
    credit_specification = optional(object({
      cpu_credits = optional(string, null)
    }), {})
    
    # CPU options
    cpu_options = optional(object({
      core_count = optional(number, null)
      threads_per_core = optional(number, null)
      amd_sev_snp = optional(string, null)
    }), {})
    
    # Enclave options
    enclave_options = optional(object({
      enabled = optional(bool, false)
    }), {})
    
    # Instance market options
    instance_market_options = optional(object({
      market_type = optional(string, null)
      spot_options = optional(object({
        max_price = optional(string, null)
        spot_instance_type = optional(string, null)
        block_duration_minutes = optional(number, null)
        valid_until = optional(string, null)
        instance_interruption_behavior = optional(string, null)
      }), {})
    }), {})
    
    # License specifications
    license_specifications = optional(list(object({
      license_configuration_arn = string
    })), [])
    
    # Maintenance options
    maintenance_options = optional(object({
      auto_recovery = optional(string, null)
    }), {})
    
    # Private DNS name options
    private_dns_name_options = optional(object({
      hostname_type = optional(string, null)
      enable_resource_name_dns_a_record = optional(bool, null)
      enable_resource_name_dns_aaaa_record = optional(bool, null)
    }), {})
    
    # Launch template
    launch_template = optional(object({
      id = optional(string, null)
      name = optional(string, null)
      version = optional(string, null)
    }), {})
    
    # Timeouts
    timeouts = optional(object({
      create = optional(string, null)
      update = optional(string, null)
      delete = optional(string, null)
    }), {})
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ec2_launch_templates" {
  description = "Map of EC2 launch templates to create"
  type = map(object({
    name = string
    description = optional(string, null)
    update_default_version = optional(bool, false)
    default_version = optional(number, null)
    latest_version = optional(number, null)
    
    # Block device mappings
    block_device_mappings = optional(list(object({
      device_name = optional(string, null)
      ebs = optional(object({
        delete_on_termination = optional(bool, null)
        encrypted = optional(bool, null)
        iops = optional(number, null)
        kms_key_id = optional(string, null)
        snapshot_id = optional(string, null)
        throughput = optional(number, null)
        volume_size = optional(number, null)
        volume_type = optional(string, null)
      }), {})
      no_device = optional(bool, null)
      virtual_name = optional(string, null)
    })), [])
    
    # Capacity reservation specification
    capacity_reservation_specification = optional(object({
      capacity_reservation_preference = optional(string, null)
      capacity_reservation_target = optional(object({
        capacity_reservation_id = optional(string, null)
        capacity_reservation_resource_group_arn = optional(string, null)
      }), {})
    }), {})
    
    # CPU options
    cpu_options = optional(object({
      core_count = optional(number, null)
      threads_per_core = optional(number, null)
      amd_sev_snp = optional(string, null)
    }), {})
    
    # Credit specification
    credit_specification = optional(object({
      cpu_credits = optional(string, null)
    }), {})
    
    # Disable API stop
    disable_api_stop = optional(bool, false)
    
    # Disable API termination
    disable_api_termination = optional(bool, false)
    
    # EBS optimized
    ebs_optimized = optional(bool, null)
    
    # Elastic GPU specifications
    elastic_gpu_specifications = optional(list(object({
      type = string
    })), [])
    
    # Elastic inference accelerator
    elastic_inference_accelerator = optional(object({
      type = string
    }), {})
    
    # Enclave options
    enclave_options = optional(object({
      enabled = optional(bool, false)
    }), {})
    
    # Hibernation options
    hibernation_options = optional(object({
      configured = optional(bool, false)
    }), {})
    
    # IAM instance profile
    iam_instance_profile = optional(object({
      arn = optional(string, null)
      name = optional(string, null)
    }), {})
    
    # Image ID
    image_id = optional(string, null)
    
    # Instance init script
    instance_initiated_shutdown_behavior = optional(string, null)
    
    # Instance market options
    instance_market_options = optional(object({
      market_type = optional(string, null)
      spot_options = optional(object({
        max_price = optional(string, null)
        spot_instance_type = optional(string, null)
        block_duration_minutes = optional(number, null)
        valid_until = optional(string, null)
        instance_interruption_behavior = optional(string, null)
      }), {})
    }), {})
    
    # Instance requirements
    instance_requirements = optional(object({
      accelerator_count = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      accelerator_manufacturers = optional(list(string), [])
      accelerator_names = optional(list(string), [])
      accelerator_total_memory_mib = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      accelerator_types = optional(list(string), [])
      allowed_instance_types = optional(list(string), [])
      bare_metal = optional(string, null)
      baseline_ebs_bandwidth_mbps = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      burstable_performance = optional(string, null)
      cpu_manufacturers = optional(list(string), [])
      excluded_instance_types = optional(list(string), [])
      instance_generations = optional(list(string), [])
      local_storage = optional(string, null)
      local_storage_types = optional(list(string), [])
      memory_gib_per_vcpu = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      memory_mib = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      network_bandwidth_gbps = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      network_interface_count = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      on_demand_max_price_percentage_over_lowest_price = optional(number, null)
      require_hibernate_support = optional(bool, null)
      spot_max_price_percentage_over_lowest_price = optional(number, null)
      total_local_storage_gb = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
      vcpu_count = optional(object({
        min = optional(number, null)
        max = optional(number, null)
      }), {})
    }), {})
    
    # Instance type
    instance_type = optional(string, null)
    
    # Kernel ID
    kernel_id = optional(string, null)
    
    # Key name
    key_name = optional(string, null)
    
    # License specifications
    license_specifications = optional(list(object({
      license_configuration_arn = string
    })), [])
    
    # Maintenance options
    maintenance_options = optional(object({
      auto_recovery = optional(string, null)
    }), {})
    
    # Metadata options
    metadata_options = optional(object({
      http_endpoint = optional(string, null)
      http_protocol_ipv6 = optional(string, null)
      http_put_response_hop_limit = optional(number, null)
      http_tokens = optional(string, null)
      instance_metadata_tags = optional(string, null)
    }), {})
    
    # Monitoring
    monitoring = optional(object({
      enabled = optional(bool, null)
    }), {})
    
    # Network interfaces
    network_interfaces = optional(list(object({
      associate_carrier_ip_address = optional(bool, null)
      associate_public_ip_address = optional(bool, null)
      delete_on_termination = optional(bool, null)
      description = optional(string, null)
      device_index = optional(number, null)
      groups = optional(list(string), [])
      interface_type = optional(string, null)
      ipv4_address_count = optional(number, null)
      ipv4_addresses = optional(list(string), [])
      ipv4_prefix_count = optional(number, null)
      ipv4_prefixes = optional(list(string), [])
      ipv6_address_count = optional(number, null)
      ipv6_addresses = optional(list(string), [])
      ipv6_prefix_count = optional(number, null)
      ipv6_prefixes = optional(list(string), [])
      network_card_index = optional(number, null)
      network_interface_id = optional(string, null)
      private_ip_address = optional(string, null)
      private_ip_list = optional(list(string), [])
      private_ip_list_enabled = optional(bool, null)
      secondary_private_ip_address_count = optional(number, null)
      subnet_id = optional(string, null)
    })), [])
    
    # Placement
    placement = optional(object({
      affinity = optional(string, null)
      availability_zone = optional(string, null)
      group_name = optional(string, null)
      host_id = optional(string, null)
      host_resource_group_arn = optional(string, null)
      partition_number = optional(number, null)
      spread_domain = optional(string, null)
      tenancy = optional(string, null)
    }), {})
    
    # Private DNS name options
    private_dns_name_options = optional(object({
      enable_resource_name_dns_a_record = optional(bool, null)
      enable_resource_name_dns_aaaa_record = optional(bool, null)
      hostname_type = optional(string, null)
    }), {})
    
    # RAM disk ID
    ram_disk_id = optional(string, null)
    
    # Security group names
    security_group_names = optional(list(string), [])
    
    # Tag specifications
    tag_specifications = optional(list(object({
      resource_type = string
      tags = optional(map(string), {})
    })), [])
    
    # User data
    user_data = optional(string, null)
    
    # VPC security group IDs
    vpc_security_group_ids = optional(list(string), [])
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ec2_spot_instances" {
  description = "Map of EC2 spot instances to create"
  type = map(object({
    name = string
    ami = optional(string, null)
    instance_type = optional(string, "t3.micro")
    availability_zone = optional(string, null)
    subnet_id = optional(string, null)
    vpc_security_group_ids = optional(list(string), [])
    
    # Spot configuration
    spot_price = optional(string, null)
    spot_type = optional(string, "one-time")
    block_duration_minutes = optional(number, null)
    instance_interruption_behavior = optional(string, "terminate")
    valid_from = optional(string, null)
    valid_until = optional(string, null)
    
    # Other configurations (same as regular instances)
    key_name = optional(string, null)
    iam_instance_profile = optional(string, null)
    user_data = optional(string, null)
    monitoring = optional(bool, false)
    tenancy = optional(string, "default")
    placement_group = optional(string, null)
    hibernation = optional(bool, false)
    
    # Storage configuration
    root_block_device = optional(list(object({
      volume_type = optional(string, "gp3")
      volume_size = optional(number, 8)
      iops = optional(number, null)
      throughput = optional(number, null)
      encrypted = optional(bool, true)
      delete_on_termination = optional(bool, true)
      device_name = optional(string, "/dev/xvda")
      tags = optional(map(string), {})
    })), [])
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "ec2_autoscaling_groups" {
  description = "Map of EC2 Auto Scaling Groups to create"
  type = map(object({
    name = string
    max_size = number
    min_size = number
    desired_capacity = optional(number, null)
    default_cooldown = optional(number, 300)
    health_check_grace_period = optional(number, 300)
    health_check_type = optional(string, "EC2")
    force_delete = optional(bool, false)
    force_delete_warm_pool = optional(bool, false)
    termination_policies = optional(list(string), [])
    suspended_processes = optional(list(string), [])
    target_group_arns = optional(list(string), [])
    load_balancers = optional(list(string), [])
    vpc_zone_identifier = optional(list(string), [])
    
    # Launch template
    launch_template = optional(object({
      id = optional(string, null)
      name = optional(string, null)
      version = optional(string, null)
    }), {})
    
    # Mixed instances policy
    mixed_instances_policy = optional(object({
      instances_distribution = optional(object({
        on_demand_allocation_strategy = optional(string, null)
        on_demand_base_capacity = optional(number, null)
        on_demand_percentage_above_base_capacity = optional(number, null)
        spot_allocation_strategy = optional(string, null)
        spot_instance_pools = optional(number, null)
        spot_max_price = optional(string, null)
      }), {})
      launch_template = optional(object({
        launch_template_specification = optional(object({
          launch_template_id = optional(string, null)
          launch_template_name = optional(string, null)
          version = optional(string, null)
        }), {})
        override = optional(list(object({
          instance_type = optional(string, null)
          weighted_capacity = optional(string, null)
          launch_template_specification = optional(object({
            launch_template_id = optional(string, null)
            launch_template_name = optional(string, null)
            version = optional(string, null)
          }), {})
        })), [])
      }), {})
    }), {})
    
    # Instance refresh
    instance_refresh = optional(object({
      strategy = optional(string, "Rolling")
      preferences = optional(object({
        min_healthy_percentage = optional(number, null)
        max_healthy_percentage = optional(number, null)
        instance_warmup = optional(number, null)
        checkpoint_delay = optional(number, null)
        checkpoint_percentages = optional(list(number), [])
        auto_rollback = optional(bool, null)
        scale_in_protected_instances = optional(string, null)
        standby_instances = optional(string, null)
      }), {})
      triggers = optional(list(string), [])
    }), {})
    
    # Warm pool
    warm_pool = optional(object({
      max_group_prepared_capacity = optional(number, null)
      min_size = optional(number, null)
      pool_state = optional(string, null)
      instance_reuse_policy = optional(object({
        reuse_on_scale_in = optional(bool, null)
      }), {})
    }), {})
    
    # Tags
    tags = optional(list(object({
      key = string
      value = string
      propagate_at_launch = bool
    })), [])
  }))
  default = {}
}

variable "ec2_launch_configurations" {
  description = "Map of EC2 Launch Configurations to create"
  type = map(object({
    name = string
    image_id = string
    instance_type = string
    key_name = optional(string, null)
    security_groups = optional(list(string), [])
    vpc_classic_link_security_groups = optional(list(string), [])
    vpc_classic_link_id = optional(string, null)
    user_data = optional(string, null)
    user_data_base64 = optional(string, null)
    enable_monitoring = optional(bool, true)
    ebs_optimized = optional(bool, null)
    associate_public_ip_address = optional(bool, null)
    placement_tenancy = optional(string, null)
    spot_price = optional(string, null)
    iam_instance_profile = optional(string, null)
    
    # Root block device
    root_block_device = optional(list(object({
      volume_type = optional(string, "standard")
      volume_size = optional(number, 8)
      iops = optional(number, null)
      throughput = optional(number, null)
      delete_on_termination = optional(bool, true)
      encrypted = optional(bool, false)
      device_name = optional(string, "/dev/xvda")
      snapshot_id = optional(string, null)
      volume_size_gb = optional(number, null)
    })), [])
    
    # EBS block devices
    ebs_block_device = optional(list(object({
      device_name = string
      volume_type = optional(string, "standard")
      volume_size = optional(number, 8)
      iops = optional(number, null)
      throughput = optional(number, null)
      delete_on_termination = optional(bool, true)
      encrypted = optional(bool, false)
      snapshot_id = optional(string, null)
      volume_size_gb = optional(number, null)
    })), [])
    
    # Ephemeral block devices
    ephemeral_block_device = optional(list(object({
      device_name = string
      virtual_name = string
      no_device = optional(bool, null)
    })), [])
    
    # Metadata options
    metadata_options = optional(object({
      http_endpoint = optional(string, "enabled")
      http_tokens = optional(string, "required")
      http_put_response_hop_limit = optional(number, 2)
      http_protocol_ipv6 = optional(string, "disabled")
      instance_metadata_tags = optional(string, "disabled")
    }), {})
  }))
  default = {}
}

# ==============================================================================
# Enhanced Transit Gateway Configuration Variables
# ==============================================================================

variable "transit_gateways" {
  description = "Map of Transit Gateways to create"
  type = map(object({
    name = string
    description = optional(string, null)
    
    # Basic configuration
    amazon_side_asn = optional(number, 64512)
    auto_accept_shared_attachments = optional(string, "disable")
    default_route_table_association = optional(string, "enable")
    default_route_table_propagation = optional(string, "enable")
    dns_support = optional(string, "enable")
    vpn_ecmp_support = optional(string, "enable")
    multicast_support = optional(string, "disable")
    
    # Advanced configuration
    transit_gateway_cidr_blocks = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_vpc_attachments" {
  description = "Map of Transit Gateway VPC attachments to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    vpc_id = string
    subnet_ids = list(string)
    
    # Basic configuration
    appliance_mode_support = optional(string, "disable")
    dns_support = optional(string, "enable")
    ipv6_support = optional(string, "disable")
    
    # Route table configuration
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_peering_attachments" {
  description = "Map of Transit Gateway peering attachments to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    peer_transit_gateway_id = string
    peer_region = string
    peer_account_id = optional(string, null)
    
    # Configuration
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_vpn_attachments" {
  description = "Map of Transit Gateway VPN attachments to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    vpn_connection_id = string
    
    # Configuration
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_dx_gateway_attachments" {
  description = "Map of Transit Gateway Direct Connect Gateway attachments to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    dx_gateway_id = string
    
    # Configuration
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_connect_attachments" {
  description = "Map of Transit Gateway Connect attachments to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    transport_attachment_id = string
    transit_gateway_address = optional(string, null)
    peer_address = optional(string, null)
    bgp_options = optional(object({
      peer_asn = number
      transit_gateway_address = optional(string, null)
      peer_address = optional(string, null)
    }), {})
    
    # Configuration
    transit_gateway_default_route_table_association = optional(bool, true)
    transit_gateway_default_route_table_propagation = optional(bool, true)
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_route_tables" {
  description = "Map of Transit Gateway route tables to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    
    # Configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_route_table_associations" {
  description = "Map of Transit Gateway route table associations to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
    
    # Advanced configuration
    replace_existing_association = optional(bool, false)
  }))
  default = {}
}

variable "transit_gateway_route_table_propagations" {
  description = "Map of Transit Gateway route table propagations to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
    
    # Advanced configuration
    replace_existing_propagation = optional(bool, false)
  }))
  default = {}
}

variable "transit_gateway_routes" {
  description = "Map of Transit Gateway routes to create"
  type = map(object({
    name = string
    destination_cidr_block = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
    
    # Advanced configuration
    blackhole = optional(bool, false)
  }))
  default = {}
}

variable "transit_gateway_multicast_domains" {
  description = "Map of Transit Gateway multicast domains to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    
    # Configuration
    auto_accept_shared_associations = optional(string, "disable")
    igmpv2_support = optional(string, "disable")
    static_sources_support = optional(string, "disable")
    
    # Advanced configuration
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_multicast_domain_associations" {
  description = "Map of Transit Gateway multicast domain associations to create"
  type = map(object({
    name = string
    transit_gateway_multicast_domain_id = string
    transit_gateway_attachment_id = string
    subnet_id = string
  }))
  default = {}
}

variable "transit_gateway_multicast_group_members" {
  description = "Map of Transit Gateway multicast group members to create"
  type = map(object({
    name = string
    transit_gateway_multicast_domain_id = string
    group_ip_address = string
    network_interface_id = string
  }))
  default = {}
}

variable "transit_gateway_multicast_group_sources" {
  description = "Map of Transit Gateway multicast group sources to create"
  type = map(object({
    name = string
    transit_gateway_multicast_domain_id = string
    group_ip_address = string
    network_interface_id = string
  }))
  default = {}
}

variable "transit_gateway_policy_tables" {
  description = "Map of Transit Gateway policy tables to create"
  type = map(object({
    name = string
    transit_gateway_id = string
    
    # Configuration
    state = optional(string, "available")
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_policy_table_entries" {
  description = "Map of Transit Gateway policy table entries to create"
  type = map(object({
    name = string
    transit_gateway_policy_table_id = string
    policy_rule = object({
      source_cidrs = list(string)
      destination_cidrs = list(string)
      protocol = optional(string, "-1")
      source_ports = optional(list(string), [])
      destination_ports = optional(list(string), [])
    })
    target_attachment_id = string
  }))
  default = {}
}

variable "transit_gateway_prefix_list_references" {
  description = "Map of Transit Gateway prefix list references to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    prefix_list_id = string
    transit_gateway_attachment_id = string
    blackhole = optional(bool, false)
  }))
  default = {}
}

variable "transit_gateway_connect_peers" {
  description = "Map of Transit Gateway Connect peers to create"
  type = map(object({
    name = string
    transit_gateway_attachment_id = string
    transit_gateway_address = optional(string, null)
    peer_address = optional(string, null)
    bgp_options = optional(object({
      peer_asn = number
      transit_gateway_address = optional(string, null)
      peer_address = optional(string, null)
    }), {})
    
    # Configuration
    inside_cidr_blocks = optional(list(string), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "transit_gateway_route_table_routes" {
  description = "Map of Transit Gateway route table routes to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    destination_cidr_block = string
    transit_gateway_attachment_id = optional(string, null)
    blackhole = optional(bool, false)
  }))
  default = {}
}

variable "transit_gateway_route_table_vpc_attachments" {
  description = "Map of Transit Gateway route table VPC attachments to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
  }))
  default = {}
}

variable "transit_gateway_route_table_peering_attachments" {
  description = "Map of Transit Gateway route table peering attachments to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
  }))
  default = {}
}

variable "transit_gateway_route_table_vpn_attachments" {
  description = "Map of Transit Gateway route table VPN attachments to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
  }))
  default = {}
}

variable "transit_gateway_route_table_dx_gateway_attachments" {
  description = "Map of Transit Gateway route table Direct Connect Gateway attachments to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
  }))
  default = {}
}

variable "transit_gateway_route_table_connect_attachments" {
  description = "Map of Transit Gateway route table Connect attachments to create"
  type = map(object({
    name = string
    transit_gateway_route_table_id = string
    transit_gateway_attachment_id = string
  }))
  default = {}
}

# ==============================================================================
# AWS Budgets and Cost Usage Reports Module Variables
# ==============================================================================

# ==============================================================================
# Budgets Configuration
# ==============================================================================

variable "budgets" {
  description = "Map of AWS Budgets to create"
  type = map(object({
    name = string
    budget_type = string
    limit_amount = string
    limit_unit = string
    time_period_start = optional(string, null)
    time_period_end = optional(string, null)
    time_unit = optional(string, "MONTHLY")
    
    # Cost filters
    cost_filters = optional(map(list(string)), {})
    
    # Cost types
    cost_types = optional(object({
      include_credit = optional(bool, null)
      include_discount = optional(bool, null)
      include_other_subscription = optional(bool, null)
      include_recurring = optional(bool, null)
      include_refund = optional(bool, null)
      include_subscription = optional(bool, null)
      include_support = optional(bool, null)
      include_tax = optional(bool, null)
      include_upfront = optional(bool, null)
      use_amortized = optional(bool, null)
      use_blended = optional(bool, null)
    }), {})
    
    # Notifications
    notifications = optional(list(object({
      comparison_operator = string
      threshold = number
      threshold_type = string
      notification_type = string
      subscriber_email_addresses = optional(list(string), [])
      subscriber_sns_topic_arns = optional(list(string), [])
    })), [])
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Budget Actions Configuration
# ==============================================================================

variable "budget_actions" {
  description = "Map of AWS Budget Actions to create"
  type = map(object({
    name = string
    budget_key = string
    action_type = string
    approval_model = string
    execution_role_arn = optional(string, null)
    action_threshold = object({
      action_threshold_value = number
      action_threshold_type = string
    })
    definition = object({
      iam_action_definition = optional(object({
        policy_arn = string
        roles = optional(list(string), [])
        groups = optional(list(string), [])
        users = optional(list(string), [])
      }), {})
      scp_action_definition = optional(object({
        policy_id = string
        target_ids = list(string)
      }), {})
      ssm_action_definition = optional(object({
        action_sub_type = string
        region = string
        instance_ids = list(string)
      }), {})
    })
    subscribers = optional(list(object({
      address = string
      subscription_type = string
    })), [])
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "create_budget_action_role" {
  description = "Whether to create an IAM role for budget actions"
  type        = bool
  default     = false
}

variable "budget_action_role_name" {
  description = "Name for the IAM role used by budget actions"
  type        = string
  default     = null
}

variable "budget_action_role_path" {
  description = "Path for the IAM role used by budget actions"
  type        = string
  default     = "/"
}

variable "budget_action_role_permissions_boundary" {
  description = "Permissions boundary for the IAM role used by budget actions"
  type        = string
  default     = null
}

# ==============================================================================
# Cost Usage Report Configuration
# ==============================================================================

variable "create_cost_usage_report" {
  description = "Whether to create a Cost Usage Report"
  type        = bool
  default     = false
}

variable "cost_usage_report" {
  description = "Configuration for Cost Usage Report"
  type = object({
    name = string
    time_unit = string
    format = string
    compression = string
    additional_schema_elements = list(string)
    s3_bucket = string
    s3_region = string
    additional_artifacts = optional(list(string), [])
    report_versioning = optional(string, "OVERWRITE_REPORT")
    refresh_closed_reports = optional(bool, true)
    report_frequency = optional(string, "DAILY")
  })
  default = {
    name = "cost-usage-report"
    time_unit = "HOURLY"
    format = "Parquet"
    compression = "Parquet"
    additional_schema_elements = ["RESOURCES"]
    s3_bucket = "my-cost-usage-reports"
    s3_region = "us-east-1"
  }
}

variable "create_s3_bucket" {
  description = "Whether to create an S3 bucket for Cost Usage Reports"
  type        = bool
  default     = false
}

# ==============================================================================
# Cost Anomaly Detection Configuration
# ==============================================================================

variable "cost_anomaly_monitors" {
  description = "Map of Cost Anomaly Monitors to create"
  type = map(object({
    name = string
    monitor_type = string
    monitor_specification = optional(string, null)
    dimensional_value_count = optional(number, null)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "cost_anomaly_subscriptions" {
  description = "Map of Cost Anomaly Subscriptions to create"
  type = map(object({
    name = string
    monitor_arn_list = list(string)
    subscribers = list(object({
      address = string
      type = string
    }))
    threshold = optional(number, null)
    frequency = optional(string, "DAILY")
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Cost Allocation Tags Configuration
# ==============================================================================

variable "cost_allocation_tags" {
  description = "Map of Cost Allocation Tags to create"
  type = map(object({
    tag_key = string
    status = optional(string, "Active")
  }))
  default = {}
}

# ==============================================================================
# Savings Plans Configuration
# ==============================================================================

variable "savings_plans" {
  description = "Map of Savings Plans to create"
  type = map(object({
    name = string
    commitment = string
    upfront_payment_amount = optional(string, null)
    payment_option = string
    purchase_time = string
    term = string
    savings_plan_type = string
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Reserved Instances Configuration
# ==============================================================================

variable "reserved_instances" {
  description = "Map of Reserved Instances to create"
  type = map(object({
    name = string
    instance_count = number
    instance_type = string
    offering_type = string
    platform = string
    scope = string
    availability_zone = optional(string, null)
    instance_tenancy = optional(string, "default")
    offering_class = optional(string, "standard")
    payment_option = optional(string, "All Upfront")
    term_length = optional(number, 1)
    tags = optional(map(string), {})
  }))
  default = {}
}

# ==============================================================================
# Cost Optimization Recommendations Configuration
# ==============================================================================

variable "enable_cost_optimization_recommendations" {
  description = "Whether to enable cost optimization recommendations"
  type        = bool
  default     = false
}

variable "cost_optimization_recommendation_types" {
  description = "Types of cost optimization recommendations to enable"
  type = list(string)
  default = [
    "EC2_INSTANCE_RIGHTSIZING",
    "EC2_INSTANCE_SCHEDULING",
    "EC2_RESERVED_INSTANCE_OPTIMIZATION",
    "RDS_INSTANCE_RIGHTSIZING",
    "RDS_RESERVED_INSTANCE_OPTIMIZATION",
    "S3_STORAGE_OPTIMIZATION",
    "LAMBDA_RIGHTSIZING"
  ]
}

# ==============================================================================
# Cost Explorer Configuration
# ==============================================================================

variable "enable_cost_explorer" {
  description = "Whether to enable Cost Explorer"
  type        = bool
  default     = true
}

variable "cost_explorer_queries" {
  description = "Map of Cost Explorer queries to create"
  type = map(object({
    name = string
    query = object({
      time_period = object({
        start = string
        end = string
      })
      granularity = string
      filter = optional(object({
        and = optional(list(object({})), [])
        or = optional(list(object({})), [])
        not = optional(object({}), {})
        dimensions = optional(object({
          key = string
          values = list(string)
        }), {})
        tags = optional(object({
          key = string
          values = list(string)
        }), {})
        cost_categories = optional(object({
          key = string
          values = list(string)
        }), {})
      }), {})
      metrics = list(string)
      group_by = optional(list(object({
        type = string
        key = optional(string, null)
      })), [])
    })
  }))
  default = {}
}

# ==============================================================================
# Cost Categories Configuration
# ==============================================================================

variable "cost_categories" {
  description = "Map of Cost Categories to create"
  type = map(object({
    name = string
    rule_version = string
    rules = list(object({
      value = string
      rule = object({
        and = optional(list(object({})), [])
        cost_category = optional(object({
          key = string
          values = list(string)
          match_options = list(string)
        }), {})
        dimension = optional(object({
          key = string
          values = list(string)
          match_options = list(string)
        }), {})
        not = optional(object({}), {})
        or = optional(list(object({})), [])
        tags = optional(object({
          key = string
          values = list(string)
          match_options = list(string)
        }), {})
      })
    }))
    split_charge_rules = optional(list(object({
      source = string
      targets = list(string)
      method = string
      parameters = optional(list(object({
        type = string
        values = list(string)
      })), [])
    })), [])
  }))
  default = {}
}

# ==============================================================================
# AWS Network Firewall Module Variables
# ==============================================================================

# ==============================================================================
# Network Firewall Configuration
# ==============================================================================

variable "network_firewalls" {
  description = "Map of Network Firewalls to create"
  type = map(object({
    name = string
    description = optional(string, null)
    
    # Basic configuration
    firewall_policy_arn = optional(string, null)
    vpc_id = optional(string, null)
    subnet_mappings = list(object({
      subnet_id = string
      ip_address_type = optional(string, "DUALSTACK")
    }))
    
    # Advanced configuration
    delete_protection = optional(bool, false)
    firewall_policy_change_protection = optional(bool, false)
    subnet_change_protection = optional(bool, false)
    
    # Encryption configuration
    encryption_configuration = optional(object({
      key_id = optional(string, null)
      type = optional(string, "AWS_OWNED_KMS_KEY")
    }), {})
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_policies" {
  description = "Map of Network Firewall Policies to create"
  type = map(object({
    name = string
    description = optional(string, null)
    
    # Stateful rule group references
    stateful_rule_group_references = optional(list(object({
      resource_arn = string
      priority = optional(number, null)
    })), [])
    
    # Stateless rule group references
    stateless_rule_group_references = optional(list(object({
      resource_arn = string
      priority = number
    })), [])
    
    # Stateful default actions
    stateful_default_actions = optional(list(string), ["aws:forward_to_sfe"])
    
    # Stateful engine options
    stateful_engine_options = optional(object({
      rule_order = optional(string, "DEFAULT_ACTION_ORDER")
    }), {})
    
    # Stateless default actions
    stateless_default_actions = optional(list(string), ["aws:forward_to_sfe"])
    
    # Stateless fragment default actions
    stateless_fragment_default_actions = optional(list(string), ["aws:forward_to_sfe"])
    
    # TLS inspection configuration
    tls_inspection_configuration_arn = optional(string, null)
    
    # Policy variables
    policy_variables = optional(object({
      rule_variables = optional(map(object({
        definition = list(string)
      })), {})
    }), {})
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_rule_groups" {
  description = "Map of Network Firewall Rule Groups to create"
  type = map(object({
    name = string
    description = optional(string, null)
    type = string
    capacity = number
    
    # Stateful rule group configuration
    rule_group = optional(object({
      rule_variables = optional(object({
        ip_sets = optional(map(object({
          definition = list(string)
        })), {})
        port_sets = optional(map(object({
          definition = list(string)
        })), {})
      }), {})
      reference_sets = optional(object({
        ip_set_references = optional(map(object({
          reference_arn = string
        })), {})
      }), {})
      rules_source = object({
        rules_source_list = optional(object({
          targets = list(string)
          target_types = list(string)
          generated_rules_type = string
        }), {})
        rules_string = optional(string, null)
        stateful_rules = optional(list(object({
          action = string
          header = object({
            destination = string
            destination_port = string
            direction = string
            protocol = string
            source = string
            source_port = string
          })
          rule_options = list(object({
            keyword = string
            settings = optional(list(string), [])
          }))
        })), [])
        stateless_rules_and_custom_actions = optional(object({
          custom_actions = optional(list(object({
            action_definition = object({
              publish_metric_action = object({
                dimensions = list(object({
                  value = string
                }))
              })
            })
            action_name = string
          })), [])
          stateless_rules = list(object({
            priority = number
            rule_definition = object({
              actions = list(string)
              match_attributes = object({
                destination_ports = optional(list(object({
                  from_port = number
                  to_port = number
                })), [])
                destinations = optional(list(object({
                  address_definition = string
                })), [])
                protocols = optional(list(number), [])
                source_ports = optional(list(object({
                  from_port = number
                  to_port = number
                })), [])
                sources = optional(list(object({
                  address_definition = string
                })), [])
                tcp_flags = optional(list(object({
                  flags = list(string)
                  masks = optional(list(string), [])
                })), [])
              })
            })
          }))
        }), {})
      })
    }), {})
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_logging_configurations" {
  description = "Map of Network Firewall Logging Configurations to create"
  type = map(object({
    firewall_arn = string
    
    # Logging configuration
    logging_configuration = object({
      log_destination_configs = list(object({
        log_destination = object({
          bucket_name = optional(string, null)
          log_group = optional(string, null)
          delivery_stream = optional(string, null)
        })
        log_destination_type = string
        log_type = string
      }))
    })
  }))
  default = {}
}

variable "network_firewall_firewall_policies" {
  description = "Map of Network Firewall Firewall Policies to create"
  type = map(object({
    name = string
    description = optional(string, null)
    
    # Policy configuration
    firewall_policy = object({
      stateful_default_actions = optional(list(string), ["aws:forward_to_sfe"])
      stateless_default_actions = optional(list(string), ["aws:forward_to_sfe"])
      stateless_fragment_default_actions = optional(list(string), ["aws:forward_to_sfe"])
      
      stateful_rule_group_references = optional(list(object({
        resource_arn = string
        priority = optional(number, null)
      })), [])
      
      stateless_rule_group_references = optional(list(object({
        resource_arn = string
        priority = number
      })), [])
      
      stateful_engine_options = optional(object({
        rule_order = optional(string, "DEFAULT_ACTION_ORDER")
      }), {})
      
      tls_inspection_configuration_arn = optional(string, null)
      
      policy_variables = optional(object({
        rule_variables = optional(map(object({
          definition = list(string)
        })), {})
      }), {})
    })
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_tls_inspection_configurations" {
  description = "Map of Network Firewall TLS Inspection Configurations to create"
  type = map(object({
    name = string
    description = optional(string, null)
    
    # TLS inspection configuration
    tls_inspection_configuration = object({
      server_certificate_configurations = list(object({
        certificate_authority_arn = optional(string, null)
        check_certificate_revocation_status = optional(object({
          revoked_status_action = optional(string, null)
          unknown_status_action = optional(string, null)
        }), {})
        scopes = optional(list(object({
          destination_ports = optional(list(object({
            from_port = number
            to_port = number
          })), [])
          destinations = optional(list(object({
            address_definition = string
          })), [])
          protocols = optional(list(number), [])
          source_ports = optional(list(object({
            from_port = number
            to_port = number
          })), [])
          sources = optional(list(object({
            address_definition = string
          })), [])
        })), [])
        server_certificates = optional(list(object({
          resource_arn = string
        })), [])
      }))
    })
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_rule_groups_stateful" {
  description = "Map of Stateful Network Firewall Rule Groups to create"
  type = map(object({
    name = string
    description = optional(string, null)
    capacity = number
    
    # Stateful rule group configuration
    rule_group = object({
      rule_variables = optional(object({
        ip_sets = optional(map(object({
          definition = list(string)
        })), {})
        port_sets = optional(map(object({
          definition = list(string)
        })), {})
      }), {})
      reference_sets = optional(object({
        ip_set_references = optional(map(object({
          reference_arn = string
        })), {})
      }), {})
      rules_source = object({
        rules_source_list = optional(object({
          targets = list(string)
          target_types = list(string)
          generated_rules_type = string
        }), {})
        rules_string = optional(string, null)
        stateful_rules = optional(list(object({
          action = string
          header = object({
            destination = string
            destination_port = string
            direction = string
            protocol = string
            source = string
            source_port = string
          })
          rule_options = list(object({
            keyword = string
            settings = optional(list(string), [])
          }))
        })), [])
      })
    })
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_rule_groups_stateless" {
  description = "Map of Stateless Network Firewall Rule Groups to create"
  type = map(object({
    name = string
    description = optional(string, null)
    capacity = number
    
    # Stateless rule group configuration
    rule_group = object({
      rule_variables = optional(object({
        ip_sets = optional(map(object({
          definition = list(string)
        })), {})
        port_sets = optional(map(object({
          definition = list(string)
        })), {})
      }), {})
      rules_source = object({
        stateless_rules_and_custom_actions = object({
          custom_actions = optional(list(object({
            action_definition = object({
              publish_metric_action = object({
                dimensions = list(object({
                  value = string
                }))
              })
            })
            action_name = string
          })), [])
          stateless_rules = list(object({
            priority = number
            rule_definition = object({
              actions = list(string)
              match_attributes = object({
                destination_ports = optional(list(object({
                  from_port = number
                  to_port = number
                })), [])
                destinations = optional(list(object({
                  address_definition = string
                })), [])
                protocols = optional(list(number), [])
                source_ports = optional(list(object({
                  from_port = number
                  to_port = number
                })), [])
                sources = optional(list(object({
                  address_definition = string
                })), [])
                tcp_flags = optional(list(object({
                  flags = list(string)
                  masks = optional(list(string), [])
                })), [])
              })
            })
          }))
        })
      })
    })
    
    # Tags
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "network_firewall_logging" {
  description = "Network Firewall logging configuration"
  type = object({
    enable_logging = optional(bool, false)
    log_destination_configs = optional(list(object({
      log_destination = object({
        bucket_name = optional(string, null)
        log_group = optional(string, null)
        delivery_stream = optional(string, null)
      })
      log_destination_type = string
      log_type = string
    })), [])
  })
  default = {
    enable_logging = false
    log_destination_configs = []
  }
}