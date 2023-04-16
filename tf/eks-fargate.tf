locals {
  oidc_id = split("/", aws_eks_cluster.cluster.identity[0].oidc[0].issuer)[4]
}

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
  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id
  ]
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

resource aws_eks_fargate_profile coredns_fargate_profile {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "coredns"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  selector {
    namespace = "kube-system"
    labels    = {
      k8s-app = "kube-dns"
    }
  }
  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id
  ]
}

data aws_iam_policy_document eks_load_balancer_controller_trust_policy {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${local.oidc_id}"
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "oidc.eks.us-east-1.amazonaws.com/id/${local.oidc_id}:aud"
    }
    condition {
      test     = "StringEquals"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
      variable = "oidc.eks.us-east-1.amazonaws.com/id/${local.oidc_id}:sub"
    }
  }
}

resource aws_iam_role eks_load_balancer_controller_role {
  name               = "AmazonEKSLoadBalancerControllerRole"
  assume_role_policy = data.aws_iam_policy_document.eks_load_balancer_controller_trust_policy.json
}

resource aws_iam_policy eks_load_balancer_controller_policy {
  name   = "EksLoadBalancerControllerPolicy"
  policy = file("load_balancer_policy.json")
}

resource aws_iam_role_policy_attachment eks_load_balancer_controller_role_policy_attachment {
  policy_arn = aws_iam_policy.eks_load_balancer_controller_policy.arn
  role       = aws_iam_role.eks_load_balancer_controller_role.name
}

resource aws_eks_fargate_profile eks_load_balancer_controller_fargate_profile {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "aws-load-balancer-controller"
  pod_execution_role_arn = aws_iam_role.eks_fargate_role.arn
  selector {
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }
  }
  subnet_ids = [
    aws_subnet.private_subnet_01.id,
    aws_subnet.private_subnet_02.id
  ]
}
