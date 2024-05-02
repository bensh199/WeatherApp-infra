# Create a role for EKS node groups
resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

  # Convert to JSON format for assume role policy
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "node-group-volume-access" {
  name        = "node-group-volume-access"
  description = "A policy to allow nodes access to EBS volumes"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "VisualEditor0"
        Effect = "Allow"
        Action = [
          "ec2:DetachVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DescribeInstances",
          "ec2:DeleteTags",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeTags",
          "ec2:CreateTags",
          "ec2:DescribeVolumes",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeSnapshots",
          "ec2:CreateVolume"
        ]
        Resource = "*"
      }
    ]
  })
}

# resource "aws_iam_policy" "ExternalDNS-Role" {
#   name        = "ExternalDNS"
#   description = "Policy for Route 53 actions"
#   policy      = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["route53:ChangeResourceRecordSets"]
#         Resource = ["*"]
#       },
#       {
#         Effect   = "Allow"
#         Action   = [
#           "route53:ListHostedZones",
#           "route53:ListResourceRecordSets",
#           "route53:ListTagsForResource"
#         ]
#         Resource = ["*"]
#       }
#     ]
#   })
# }
  
# Attach policies to the EKS node group role
resource "aws_iam_role_policy_attachment" "node-group-volume-access" {
  policy_arn = "arn:aws:iam::654654166113:policy/node-group-volume-access"
  role       = aws_iam_role.nodes.name
  depends_on = [ aws_iam_policy.node-group-volume-access ]
}

# Attach policies to the EKS node group role
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AWSCodeCommitPowerUser" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitPowerUser"
  role       = aws_iam_role.nodes.name
}

# Create the EKS node group
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.Lab4-EKS.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = var.nodes_subnet_ids

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 2
    min_size     = 2
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  # Ensure the EKS node group creation depends on the attached policies
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.node-group-volume-access,
  ]
}
