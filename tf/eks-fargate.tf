resource aws_eks_fargate_profile eks_fargate_profile {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "fargate_profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  selector {
    namespace = "default"
    labels    = {
      infrastructure = "fargate"
    }
  }
}

data aws_iam_policy_document eks_fargate_assume_role {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks-fargate-pods.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource aws_iam_role eks_fargate_role {
  name               = "eksFargateRole"
  assume_role_policy = data.aws_iam_policy_document.eks_fargate_assume_role.json
}

resource aws_iam_role_policy_attachment eks_fargate_policy_attachment {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate_role.name
}