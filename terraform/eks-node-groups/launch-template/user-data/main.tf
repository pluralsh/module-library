data "cloudinit_config" "linux_eks_managed_node_group" {
  base64_encode = true
  gzip          = false
  boundary      = "//"

  # Prepend to existing user data supplied by AWS EKS
  part {
    content_type = "text/x-shellscript"
    content      = var.pre_bootstrap_user_data
  }
}

locals {
  kubelet_extra_args = var.kubelet_extra_args != {} ? join(" ", [for k, v in var.kubelet_extra_args : "${k}=${v}"]) : ""
  int_linux_default_user_data = (var.enable_bootstrap_user_data || var.user_data_template_path != "") ? base64encode(templatefile(
    coalesce(var.user_data_template_path, "${path.module}/linux_user_data.tpl"),
    {
      # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-custom-ami
      enable_bootstrap_user_data = var.enable_bootstrap_user_data
      # Required to bootstrap node
      cluster_name        = var.cluster_name
      cluster_endpoint    = var.cluster_endpoint
      cluster_auth_base64 = var.cluster_auth_base64
      # Optional
      cluster_service_ipv4_cidr = var.cluster_service_ipv4_cidr != null ? var.cluster_service_ipv4_cidr : ""
      kubelet_extra_args        = local.kubelet_extra_args
      bootstrap_extra_args      = var.bootstrap_extra_args
      pre_bootstrap_user_data   = var.pre_bootstrap_user_data
      post_bootstrap_user_data  = var.post_bootstrap_user_data
    }
  )) : ""
  linux_user_data = try(local.int_linux_default_user_data, data.cloudinit_config.linux_eks_managed_node_group.rendered)
}
