resource aws_eks_cluster cluster {
  name     = "kub-dep-demo"
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true
    public_access_cidrs     = ["0.0.0.0/0"]
    subnet_ids              = [
      aws_subnet.public_subnet_01.id,
      aws_subnet.public_subnet_02.id,
      aws_subnet.private_subnet_01.id,
      aws_subnet.private_subnet_02.id
    ]
    security_group_ids = [aws_security_group.control_plane_security_group.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

data aws_iam_policy_document eks_cluster_assume_role {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource aws_iam_role eks_cluster_role {
  name               = "eksClusterRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource aws_iam_role_policy_attachment eks_cluster_policy_attachment {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}
