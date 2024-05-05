resource "aws_iam_role" "dev_cluster" {
  name = "dev_cluster"
  tags = {
    Name = "dev_cluster"
  }

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

resource "aws_iam_role_policy_attachment" "dev_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dev_cluster.name
}


resource "aws_eks_cluster" "dev_cluster" {
  name     = "dev_cluster"
  role_arn = aws_iam_role.dev_cluster.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.dev_public.id,
      aws_subnet.dev_private.id
    ]
  }

  tags = {
    Name = "dev_cluster"
  }

  depends_on = [aws_iam_role_policy_attachment.dev_cluster_AmazonEKSClusterPolicy]
}
