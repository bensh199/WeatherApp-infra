# Create IAM role for the EKS cluster
resource "aws_iam_role" "Lab4-EKS" {
  name = var.cluster_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach AmazonEKSClusterPolicy to the IAM role
resource "aws_iam_role_policy_attachment" "Lab4-EKS-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.Lab4-EKS.name
}

# Create an AWS EKS cluster
resource "aws_eks_cluster" "Lab4-EKS" {
  name     = var.cluster_name
  role_arn = aws_iam_role.Lab4-EKS.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.Lab4-EKS-AmazonEKSClusterPolicy]
}

# in case more access enties to the cluster are needed, add the following blocks:
# resource "aws_eks_access_entry" "example" {
#   cluster_name      = aws_eks_cluster.example.name (Required) 
#   principal_arn     = aws_iam_role.example.arn (Required)
#   kubernetes_groups = ["group-1", "group-2"] (optional)
#   type              = "STANDARD" (optional, default is standard)
# }

# Add addons to the EKS cluster
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.Lab4-EKS.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.Lab4-EKS.name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.Lab4-EKS.name
  addon_name    = "coredns"
  addon_version = "v1.11.1-eksbuild.4"
  depends_on    = [aws_eks_node_group.private-nodes]
}

resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.Lab4-EKS.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.2.0-eksbuild.1"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name  = aws_eks_cluster.Lab4-EKS.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.29.1-eksbuild.1"
  service_account_role_arn = "arn:aws:iam::654654166113:role/AmazonEKS_EBS_CSI_DriverRole"
  depends_on    = [aws_eks_node_group.private-nodes]
}