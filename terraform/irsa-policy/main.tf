data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

module "assumable_role_console" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.14.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.role_name}"
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.serviceaccount}"]
}

resource "aws_iam_policy" "policy" {
  name_prefix = var.role_name
  description = "policy for the plural admin console"
  policy      = var.policy_json
}