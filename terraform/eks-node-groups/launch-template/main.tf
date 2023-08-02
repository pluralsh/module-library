locals {
  security_group_ids = compact(concat([var.cluster_primary_security_group_id], var.vpc_security_group_ids))
  #has_taints         = length(var.k8s_taints) > 0 || length(try(var.kubelet_extra_args["--register-with-taints"], [])) > 0
}

data "aws_ami" "ami" {
  # If more or less than a single match is returned by the search, Terraform will fail.
  # Ensure that your search is specific enough to return a single AMI ID only, or use most_recent to choose the most recent one.
  # If you want to match multiple AMIs, use the aws_ami_ids data source instead.
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name = "name"
    #values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-focal-20.04-${each.key}-server-*"]
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
  #public_key      = trimspace(tls_private_key.this[0].public_key_openssh)
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDFUvl5clm3cGh7k3ItY7JkFNWhUHqbBrxPMbqejikFADc26NBq4wmsz4cZxVroKf8J3HMhJpjDbJk0w+q43R50ndDjiJ91Y3zX7EupxzgqOhPa4GZps0csGt8e5I9xz3xvGHtefHxl7minU8Wm9CKg0GBRv3yLaan1VLn5WLqooCo6qt/PHI01oERLQeE3qdT5m3kmRZ7wSBqGQBMHfeNDvXFRVkURQ+7Ak+93TuuL/fISpjHk4P+ALbbyqXwUid7g8UgyeWBJTwOQxUSyNrJ6zn1sYq7doXHx41MZiH4RvCUmQCtp9PBgN4PwjgHOQ8/Zyk6Syaf5LtWXlqeXrJCH"

  tags = var.tags
}

resource "tls_private_key" "this" {
  count = var.create_key_pair ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}



module "user_data" {
  #source = "../user_data"
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
        #["eks.amazonaws.com/nodegroup-image=${data.aws_ami.ami.id}"],
        # TODO: I have a problem if this label needs to be passed in as a variable, because it would mean to have one launch template for each single az node group
        #["eks.amazonaws.com/nodegroup=small-burst-on-demand-us-east-2c-subnet-09231904575210d72"],
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
            #value = each.value.value != "" ? "${each.value.value}:${replace(title(replace(lower(each.value.effect), "_", " ")), " ", "")}" : replace(title(replace(lower(each.value.effect), "_", " ")), " ", "")
            #t.effect
            replace(title(replace(lower(t.effect), "_", " ")), " ", "")
          )
        ]
      ))
    }
  )
  bootstrap_extra_args    = var.bootstrap_extra_args
  user_data_template_path = var.user_data_template_path
}


resource "aws_launch_template" "this" {
  name        = var.launch_template_use_name_prefix ? null : var.launch_template_name
  name_prefix = var.launch_template_use_name_prefix ? "${var.launch_template_name}-" : null

  image_id  = coalesce(var.ami_id, data.aws_ami.ami.id)
  user_data = module.user_data.user_data

  # TODO: most of these try statements are probably unnecessary, because they are already set to default null in the variables

  block_device_mappings {
    device_name = try(var.block_device_mappings.device_name, null)

    ebs {
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


  enclave_options {
    enabled = try(var.enclave_options.enabled, false)
  }


  # # Set on node group instead
  # instance_type = var.launch_template_instance_type
  kernel_id = var.kernel_id
  key_name  = var.create_key_pair ? aws_key_pair.this[0].key_name : var.key_name

  dynamic "license_specification" {
    for_each = length(var.license_specifications) > 0 ? var.license_specifications : {}

    content {
      license_configuration_arn = license_specifications.value.license_configuration_arn
    }
  }

  #instance_market_options {
  #  market_type = try(var.instance_market_options.market_type, null)

  #  spot_options {
  #    block_duration_minutes         = try(var.instance_market_options.spot_options.block_duration_minutes, null)
  #    instance_interruption_behavior = try(var.instance_market_options.spot_options.instance_interruption_behavior, null)
  #    max_price                      = try(var.instance_market_options.spot_options.max_price, null)
  #    spot_instance_type             = try(var.instance_market_options.spot_options.spot_instance_type, null)
  #    valid_until                    = try(var.instance_market_options.spot_options.valid_until, null)
  #  }
  #}


  #metadata_options {
  #  http_endpoint               = try(var.metadata_options.http_endpoint, null)
  #  http_protocol_ipv6          = try(var.metadata_options.http_protocol_ipv6, null)
  #  http_put_response_hop_limit = try(var.metadata_options.http_put_response_hop_limit, null)
  #  http_tokens                 = try(var.metadata_options.http_tokens, null)
  #}

  #monitoring {
  #  enabled = var.enable_monitoring
  #}


  #dynamic "network_interfaces" {
  #  for_each = var.network_interfaces
  #  content {
  #    associate_carrier_ip_address = try(each.value.associate_carrier_ip_address, null)
  #    associate_public_ip_address  = try(each.value.associate_public_ip_address, null)
  #    delete_on_termination        = try(each.value.delete_on_termination, null)
  #    description                  = try(each.value.description, null)
  #    device_index                 = try(each.value.device_index, null)
  #    interface_type               = try(each.value.interface_type, null)
  #    ipv4_address_count           = try(each.value.ipv4_address_count, null)
  #    ipv4_addresses               = try(each.value.ipv4_addresses, [])
  #    ipv6_address_count           = try(each.value.ipv6_address_count, null)
  #    ipv6_addresses               = try(each.value.ipv6_addresses, [])
  #    network_interface_id         = try(each.value.network_interface_id, null)
  #    private_ip_address           = try(each.value.private_ip_address, null)
  #    # Ref: https://github.com/hashicorp/terraform-provider-aws/issues/4570
  #    security_groups = compact(concat(try(network_interfaces.value.security_groups, []), local.security_group_ids))
  #    # Set on EKS managed node group, will fail if set here
  #    # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-basics
  #    # subnet_id       = try(network_interfaces.value.subnet_id, null)
  #  }
  #}

  #placement {
  #  affinity                = try(var.placement.affinity, null)
  #  availability_zone       = try(var.placement.availability_zone, null)
  #  group_name              = try(var.placement.group_name, null)
  #  host_id                 = try(var.placement.host_id, null)
  #  host_resource_group_arn = try(var.placement.host_resource_group_arn, null)
  #  partition_number        = try(var.placement.partition_number, null)
  #  spread_domain           = try(var.placement.spread_domain, null)
  #  tenancy                 = try(var.placement.tenancy, null)
  #}


  #ram_disk_id = var.ram_disk_id

  #dynamic "tag_specifications" {
  #  for_each = toset(var.tag_specifications)

  #  content {
  #    resource_type = tag_specifications.key
  #    tags          = merge(var.tags, { Name = var.name }, var.launch_template_tags)
  #  }
  #}

  #cpu_options {
  #  core_count       = try(var.cpu_options.cpu_options.value.core_count, null)
  #  threads_per_core = try(var.cpu_options.threads_per_core, null)
  #}

  #credit_specification {
  #  cpu_credits = try(var.credit_specification.cpu_credits, null)
  #}


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
