module.aws.module.node_groups.aws_eks_node_group.workers["sysbox_s_ondemand-us-east-2c"]: Creating...
╷
│ Error: error creating EKS Node Group (pluraldev:sysbox-s-ondemand-us-east-2c-subnet-09231904575210d72): InvalidParameterException: Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]
│ {
│   RespMetadata: {
│     StatusCode: 400,
│     RequestID: "8a0f1a85-3c35-4aab-87d3-751870630e07"
│   },
│   ClusterName: "pluraldev",
│   Message_: "Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]",
│   NodegroupName: "sysbox-s-ondemand-us-east-2c-subnet-09231904575210d72"
│ }
│ 
│   with module.aws.module.node_groups.aws_eks_node_group.workers["sysbox_s_ondemand-us-east-2c"],
│   on .terraform/modules/aws.node_groups/terraform/eks-node-groups/single-az-node-groups/node_groups.tf line 1, in resource "aws_eks_node_group" "workers":
│    1: resource "aws_eks_node_group" "workers" {
│ 
╵
╷
│ Error: error creating EKS Node Group (pluraldev:sysbox-s-ondemand-us-east-2b-subnet-02fcb830dd974eaed): InvalidParameterException: Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]
│ {
│   RespMetadata: {
│     StatusCode: 400,
│     RequestID: "bdb47383-8034-4981-9424-2b34f1e8435b"
│   },
│   ClusterName: "pluraldev",
│   Message_: "Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]",
│   NodegroupName: "sysbox-s-ondemand-us-east-2b-subnet-02fcb830dd974eaed"
│ }
│ 
│   with module.aws.module.node_groups.aws_eks_node_group.workers["sysbox_s_ondemand-us-east-2b"],
│   on .terraform/modules/aws.node_groups/terraform/eks-node-groups/single-az-node-groups/node_groups.tf line 1, in resource "aws_eks_node_group" "workers":
│    1: resource "aws_eks_node_group" "workers" {
│ 
╵
╷
│ Error: error creating EKS Node Group (pluraldev:sysbox-s-ondemand-us-east-2a-subnet-0af5ea0170708e442): InvalidParameterException: Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]
│ {
│   RespMetadata: {
│     StatusCode: 400,
│     RequestID: "fe2c8e0c-d312-41fe-90d2-e9ba2c90f670"
│   },
│   ClusterName: "pluraldev",
│   Message_: "Label cannot start with reserved prefixes [kubernetes.io/, k8s.io/, eks.amazonaws.com/]",
│   NodegroupName: "sysbox-s-ondemand-us-east-2a-subnet-0af5ea0170708e442"
│ }
│ 
│   with module.aws.module.node_groups.aws_eks_node_group.workers["sysbox_s_ondemand-us-east-2a"],
│   on .terraform/modules/aws.node_groups/terraform/eks-node-groups/single-az-node-groups/node_groups.tf line 1, in resource "aws_eks_node_group" "workers":
│    1: resource "aws_eks_node_group" "workers" {