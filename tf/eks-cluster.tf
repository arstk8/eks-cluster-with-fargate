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
