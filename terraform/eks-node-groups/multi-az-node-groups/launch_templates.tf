data "aws_ami" "amis" {
  for_each    = var.launch_templates
  most_recent = true
  filter {
    name = "name"
    #values = ["ubuntu-eks/k8s_${var.kubernetes_version}/images/hvm-ssd/ubuntu-focal-20.04-${each.key}-server-*"]
    values = [each.value.ami_filter.name]
  }
}

module "launch_templates" {
  source   = "./modules/launch-template"
  for_each = var.launch_templates

  launch_template_name = lookup(each.value, "name", join("-", [var.cluster_name, each.key, random_pet.node_groups[each.key].id]))
  ami_id               = each.value.ami_id != null ? each.value.ami_id : data.aws_ami.amis[each.key].id
}
