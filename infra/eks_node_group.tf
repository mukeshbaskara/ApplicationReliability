resource "aws_iam_role" "eks_node_role" {
  name = "flyingclub-node-role"

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

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_role_AmazonEC2ContainerServiceforEC2Role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "flyingclub_ng"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [for subnet in aws_subnet.private_subnets : subnet.id]
  remote_access {
    ec2_ssh_key     = "prometheus-server-key"
  }
  scaling_config {
    desired_size = 3
    max_size     = 4
    min_size     = 2
  }
  capacity_type = "ON_DEMAND"
  instance_types = ["t2.micro"]
  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_node_role_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_role_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_role_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_node_role_AmazonEC2ContainerServiceforEC2Role,
  ]
}