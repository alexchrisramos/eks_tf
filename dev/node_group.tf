resource "aws_iam_role" "dev_nodegroup1_role" {
  name = "dev_nodegroup1_role"
  tags = {
    Name = "dev_nodegroup1_role"
  }

  assume_role_policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
            "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
        ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "dev_nodegroup1_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.dev_nodegroup1_role.name
}

resource "aws_iam_role_policy_attachment" "dev_nodegroup1_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.dev_nodegroup1_role.name
}

resource "aws_iam_role_poicy_attachment" "dev_nodegroup1_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.dev_nodegroup1_role.name
}


resource "aws_eks_node_group" "dev_nodegroup1" {
  cluster_name    = aws_eks_cluster.dev_cluster.name
  node_group_name = "dev_nodegroup1"
  node_role_arn   = aws_iam_role.dev_nodegroup1_role.arn
  subnet_ids = [
    aws_subnet.dev_public.id,
    aws_subnet.dev_private.id
  ]

  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_eks_cluster.dev_cluster,
    aws_iam_role_policy_attachment.dev_nodegroup1_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.dev_nodegroup1_AmazonEKS_CNI_Policy,
    aws_iam_role_poicy_attachment.dev_nodegroup1_AmazonEC2ContainerRegistryReadOnly,
  ]
}
