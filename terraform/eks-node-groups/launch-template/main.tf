locals {
  security_group_ids = compact(concat([var.cluster_primary_security_group_id], var.vpc_security_group_ids))
}

data "aws_ami" "ami" {
  # If more or less than a single match is returned by the search, Terraform will fail.
  # Ensure that your search is specific enough to return a single AMI ID only, or use most_recent to choose the most recent one.
  # If you want to match multiple AMIs, use the aws_ami_ids data source instead.
  most_recent = true
  owners      = var.ami_owners
  filter {
    name   = "name"
    values = [var.ami_filter_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

resource "aws_key_pair" "this" {
  count = var.create_key_pair ? 1 : 0

  key_name_prefix = var.launch_template_name
  public_key      = trimspace(tls_private_key.this[0].public_key_openssh)

  tags = var.tags
}

resource "tls_private_key" "this" {
  count = var.create_key_pair ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

module "user_data" {
  source = "github.com/pluralsh/module-library//terraform/eks-node-groups/user-data?ref=feat-ubuntu-ng"

  cluster_name = var.cluster_name

  cluster_endpoint    = coalesce(var.cluster_endpoint, data.aws_eks_cluster.this.endpoint)
  cluster_auth_base64 = coalesce(var.cluster_auth_base64, data.aws_eks_cluster.this.certificate_authority[0].data)

  cluster_service_ipv4_cidr = coalesce(var.cluster_service_ipv4_cidr, data.aws_eks_cluster.this.kubernetes_network_config[0].service_ipv4_cidr)

  enable_bootstrap_user_data = var.enable_bootstrap_user_data
  pre_bootstrap_user_data    = var.pre_bootstrap_user_data
  post_bootstrap_user_data   = var.post_bootstrap_user_data
  kubelet_extra_args = merge(
    var.kubelet_extra_args, # --node-labels and --register-with-taints are overwritten in this merge but handled seperately below
    {
      "--node-labels" = join(",", concat(
        try(var.kubelet_extra_args["--node-labels"], []),
        [for k, v in var.k8s_labels : format("%s=%s", k, v)]
    )) },
    {
      "--register-with-taints" = join(",", concat(
        try(var.kubelet_extra_args["--register-with-taints"], []),
        [for t in var.k8s_taints :
          format(
            "%s=%s:%s",
            t.key,
            t.value,
            replace(title(replace(lower(t.effect), "_", " ")), " ", "")
          )
        ]
      ))
    },
    try(var.max_pods_per_node, null) != null ? { "--max-pods" = "${var.max_pods_per_node}" } : {}
  )
  bootstrap_extra_args    = var.bootstrap_extra_args
  user_data_template_path = var.user_data_template_path
}


resource "aws_launch_template" "this" {
  name        = var.launch_template_use_name_prefix ? null : var.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${var.launch_template_name}-" : null

  image_id  = coalesce(var.ami_id, data.aws_ami.ami.id)
  user_data = module.user_data.user_data
  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings

    content {
      device_name = try(block_device_mappings.value.device_name, null)

      dynamic "ebs" {
        for_each = try([block_device_mappings.value.ebs], [])

        content {
          delete_on_termination = try(ebs.value.delete_on_termination, null)
          encrypted             = try(ebs.value.encrypted, null)
          iops                  = try(ebs.value.iops, null)
          kms_key_id            = try(ebs.value.kms_key_id, null)
          snapshot_id           = try(ebs.value.snapshot_id, null)
          throughput            = try(ebs.value.throughput, null)
          volume_size           = try(ebs.value.volume_size, null)
          volume_type           = try(ebs.value.volume_type, null)
        }
      }

      no_device    = try(block_device_mappings.value.no_device, null)
      virtual_name = try(block_device_mappings.value.virtual_name, null)
    }
  }

  default_version         = var.launch_template_default_version
  description             = var.launch_template_description
  disable_api_termination = var.disable_api_termination
  ebs_optimized           = var.ebs_optimized

  dynamic "elastic_gpu_specifications" {
    for_each = var.elastic_gpu_specifications

    content {
      type = elastic_gpu_specifications.value.type
    }
  }

  dynamic "elastic_inference_accelerator" {
    for_each = length(var.elastic_inference_accelerator) > 0 ? [var.elastic_inference_accelerator] : []

    content {
      type = elastic_inference_accelerator.value.type
    }
  }

  dynamic "enclave_options" {
    for_each = length(var.enclave_options) > 0 ? [var.enclave_options] : []

    content {
      enabled = enclave_options.value.enabled
    }
  }

  kernel_id = var.kernel_id
  key_name  = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name

  dynamic "license_specification" {
    for_each = length(var.license_specifications) > 0 ? var.license_specifications : {}

    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  dynamic "instance_market_options" {
    for_each = length(var.instance_market_options) > 0 ? [var.instance_market_options] : []
    content {
      market_type = try(instance_market_options.value.market_type, null)
      dynamic "spot_options" {
        for_each = try([instance_market_options.value.spot_options], [])

        content {
          block_duration_minutes         = try(spot_options.value.block_duration_minutes, null)
          instance_interruption_behavior = try(spot_options.value.instance_interruption_behavior, null)
          max_price                      = try(spot_options.value.max_price, null)
          spot_instance_type             = try(spot_options.value.spot_instance_type, null)
          valid_until                    = try(spot_options.value.valid_until, null)
        }
      }
    }
  }

  dynamic "metadata_options" {
    for_each = length(var.metadata_options) > 0 ? [var.metadata_options] : []

    content {
      http_endpoint               = try(metadata_options.value.http_endpoint, null)
      http_protocol_ipv6          = try(metadata_options.value.http_protocol_ipv6, null)
      http_put_response_hop_limit = try(metadata_options.value.http_put_response_hop_limit, null)
      http_tokens                 = try(metadata_options.value.http_tokens, null)
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring ? [1] : []

    content {
      enabled = var.enable_monitoring
    }
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
      ipv6_address_count           = try(each.value.ipv6_address_count, null)
      ipv6_addresses               = try(each.value.ipv6_addresses, [])
      network_interface_id         = try(each.value.network_interface_id, null)
      private_ip_address           = try(each.value.private_ip_address, null)
      security_groups              = compact(concat(try(network_interfaces.value.security_groups, []), local.security_group_ids))
    }
  }

  dynamic "placement" {
    for_each = length(var.placement) > 0 ? [var.placement] : []

    content {
      affinity                = try(placement.value.affinity, null)
      availability_zone       = try(placement.value.availability_zone, null)
      group_name              = try(placement.value.group_name, null)
      host_id                 = try(placement.value.host_id, null)
      host_resource_group_arn = try(placement.value.host_resource_group_arn, null)
      partition_number        = try(placement.value.partition_number, null)
      spread_domain           = try(placement.value.spread_domain, null)
      tenancy                 = try(placement.value.tenancy, null)
    }
  }

  ram_disk_id = var.ram_disk_id

  dynamic "tag_specifications" {
    for_each = toset(var.tag_specifications)

    content {
      resource_type = tag_specifications.key
      tags          = merge(var.tags, { Name = var.name }, var.launch_template_tags)
    }
  }

  dynamic "cpu_options" {
    for_each = length(var.cpu_options) > 0 ? [var.cpu_options] : []

    content {
      core_count       = try(cpu_options.value.core_count, null)
      threads_per_core = try(cpu_options.value.threads_per_core, null)
    }
  }

  dynamic "credit_specification" {
    for_each = length(var.credit_specification) > 0 ? [var.credit_specification] : []

    content {
      cpu_credits = try(credit_specification.value.cpu_credits, null)
    }
  }


  update_default_version = var.update_launch_template_default_version
  vpc_security_group_ids = length(var.network_interfaces) > 0 ? [] : local.security_group_ids

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}
