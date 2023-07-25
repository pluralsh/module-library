locals {
  launch_template_name = var.launch_template_name
  security_group_ids   = compact(concat([var.cluster_primary_security_group_id], var.vpc_security_group_ids))
}

data "aws_ami" "ami" {
  # If more or less than a single match is returned by the search, Terraform will fail.
  # Ensure that your search is specific enough to return a single AMI ID only, or use most_recent to choose the most recent one.
  # If you want to match multiple AMIs, use the aws_ami_ids data source instead.
  most_recent = true
  filter {
    name = "name"
    #values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-focal-20.04-${each.key}-server-*"]
    values = [var.ami_filter_name]
  }
}


module "user_data" {
  #source = "../user_data"
  source = "github.com/pluralsh/module-library//terraform/eks-node-groups/user-data?ref=feat/ubuntu-ng"

  cluster_name        = var.cluster_name
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_auth_base64

  cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr

  enable_bootstrap_user_data = var.enable_bootstrap_user_data
  pre_bootstrap_user_data    = var.pre_bootstrap_user_data
  post_bootstrap_user_data   = var.post_bootstrap_user_data
  bootstrap_extra_args       = var.bootstrap_extra_args
  user_data_template_path    = var.user_data_template_path
}


resource "aws_launch_template" "this" {
  name        = var.launch_template_use_name_prefix ? null : local.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${local.launch_template_name}-" : null

  image_id  = var.ami_id != "" ? var.ami_id : data.aws_ami.ami.id
  user_data = module.user_data.user_data

  # TODO: most of these try statements are probably unnecessary, because they are already set to default null in the variables

  block_device_mappings {
    device_name = var.block_device_mappings.device_name

    ebs = {
      delete_on_termination = try(var.block_device_mappings.ebs.delete_on_termination, null)
      encrypted             = try(var.block_device_mappings.ebs.encrypted, null)
      iops                  = try(var.block_device_mappings.ebs.iops, null)
      kms_key_id            = try(var.block_device_mappings.ebs.kms_key_id, null)
      snapshot_id           = try(var.block_device_mappings.ebs.snapshot_id, null)
      throughput            = try(var.block_device_mappings.ebs.throughput, null)
      volume_size           = try(var.block_device_mappings.ebs.volume_size, null)
      volume_type           = try(var.block_device_mappings.ebs.volume_type, null)
    }

    no_device    = try(var.block_device_mappings.no_device, null)
    virtual_name = try(var.block_device_mappings.virtual_name, null)
  }

  capacity_reservation_specification {
    capacity_reservation_preference = try(var.capacity_reservation_specification.capacity_reservation_preference, null)

    capacity_reservation_target = {
      capacity_reservation_id                 = try(var.capacity_reservation_specification.capacity_reservation_target.capacity_reservation_id, null)
      capacity_reservation_resource_group_arn = try(var.capacitiy_reservation_specification.capacity_reservation_target.capacity_reservation_resource_group_arn, null)
    }
  }

  cpu_options {
    core_count       = try(var.cpu_options.cpu_options.value.core_count, null)
    threads_per_core = try(var.cpu_options.threads_per_core, null)
  }

  credit_specification {
    cpu_credits = try(var.credit_specification.cpu_credits, null)
  }

  default_version         = var.launch_template_default_version
  description             = var.launch_template_description
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  elastic_gpu_specifications {
    type = try(var.elastic_gpu_specifications.type, null)
  }

  elastic_inference_accelerator {
    type = try(var.elastic_inference_accelerator.type, null)
  }

  enclave_options {
    enabled = var.enclave_options.enabled
  }


  instance_market_options {
    market_type = try(var.instance_market_options.market_type, null)

    spot_options = {
      block_duration_minutes         = try(var.instance_market_options.spot_options.block_duration_minutes, null)
      instance_interruption_behavior = try(var.instance_market_options.spot_options.instance_interruption_behavior, null)
      max_price                      = try(var.instance_market_options.spot_options.max_price, null)
      spot_instance_type             = try(var.instance_market_options.spot_options.spot_instance_type, null)
      valid_until                    = try(var.instance_market_options.spot_options.valid_until, null)
    }
  }

  # # Set on node group instead
  # instance_type = var.launch_template_instance_type
  kernel_id = var.kernel_id
  key_name  = var.key_name

  license_specification {
    license_configuration_arn = try(var.license_specifications.license_configuration_arn, null)
  }

  maintenance_options {
    auto_recovery = try(var.maintenance_options.auto_recovery, null)
  }

  metadata_options {
    http_endpoint               = try(var.metadata_options.http_endpoint, null)
    http_protocol_ipv6          = try(var.metadata_options.http_protocol_ipv6, null)
    http_put_response_hop_limit = try(var.metadata_options.http_put_response_hop_limit, null)
    http_tokens                 = try(var.metadata_options.http_tokens, null)
    instance_metadata_tags      = try(var.metadata_options.instance_metadata_tags, null)
  }

  monitoring {
    enabled = var.enable_monitoring
  }


  dynamic "network_interfaces" {
    for_each = var.network_interfaces
    content {
      associate_carrier_ip_address = try(each.value.associate_carrier_ip_address, null)
      associate_public_ip_address  = try(each.value.associate_public_ip_address, null)
      delete_on_termination        = try(each.value.delete_on_termination, null)
      description                  = try(each.value.description, null)
      device_index                 = try(each.value.device_index, null)
      interface_type               = try(each.value.interface_type, null)
      ipv4_address_count           = try(each.value.ipv4_address_count, null)
      ipv4_addresses               = try(each.value.ipv4_addresses, [])
      ipv4_prefix_count            = try(each.value.ipv4_prefix_count, null)
      ipv4_prefixes                = try(each.value.ipv4_prefixes, null)
      ipv6_address_count           = try(each.value.ipv6_address_count, null)
      ipv6_addresses               = try(each.value.ipv6_addresses, [])
      ipv6_prefix_count            = try(each.value.ipv6_prefix_count, null)
      ipv6_prefixes                = try(each.value.ipv6_prefixes, [])
      network_card_index           = try(each.value.network_card_index, null)
      network_interface_id         = try(each.value.network_interface_id, null)
      private_ip_address           = try(each.value.private_ip_address, null)
      # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/4570
      security_groups = compact(concat(try(network_interfaces.value.security_groups, []), local.security_group_ids))
      # Set on EKS managed node group, will fail if set here
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-basics
      # subnet_id       = try(network_interfaces.value.subnet_id, null)
    }
  }

  placement {
    affinity                = try(var.placement.affinity, null)
    availability_zone       = try(var.placement.availability_zone, null)
    group_name              = try(var.placement.group_name, null)
    host_id                 = try(var.placement.host_id, null)
    host_resource_group_arn = try(var.placement.host_resource_group_arn, null)
    partition_number        = try(var.placement.partition_number, null)
    spread_domain           = try(var.placement.spread_domain, null)
    tenancy                 = try(var.placement.tenancy, null)
  }

  private_dns_name_options = {
    enable_resource_name_dns_aaaa_record = try(var.private_dns_name_options.enable_resource_name_dns_aaaa_record, null)
    enable_resource_name_dns_a_record    = try(var.private_dns_name_options.enable_resource_name_dns_a_record, null)
    hostname_type                        = try(var.private_dns_name_options.hostname_type, null)
  }

  ram_disk_id = var.ram_disk_id

  dynamic "tag_specifications" {
    for_each = toset(var.tag_specifications)

    content {
      resource_type = tag_specifications.key
      tags          = merge(var.tags, { Name = var.name }, var.launch_template_tags)
    }
  }

  update_default_version = var.update_launch_template_default_version
  vpc_security_group_ids = length(var.network_interfaces) > 0 ? [] : local.security_group_ids

  tags = var.tags

  # TODO: check if this is needed, dont think so though
  ## Prevent premature access of policies by pods that
  ## require permissions on create/destroy that depend on nodes
  #depends_on = [
  #  aws_iam_role_policy_attachment.this,
  #]

  lifecycle {
    create_before_destroy = true
  }
}