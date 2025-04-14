provider "aws" {
  region = "ap-south-1"
}

# STEP1: CREATE SG
resource "aws_security_group" "my-sg" {
  name        = "Cluster_Server_Sg"
  description = "Cluster Server Ports"
  
  # Port 22 is required for SSH Access
  ingress {
    description     = "SSH Port"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 22s required for SSh
  egress {
    description     = "SSH Port"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port is required for All Ports
  ingress {
    description     = "All Port"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port is required for All Ports
  egress {
    description     = "All Ports"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# STEP2: CREATE EC2 USING PEM & SG
resource "aws_instance" "my-ec2" {
  ami           = "ami-00bb6a80f01f03502"  
  instance_type = "t2.medium"
  key_name      = "Devops project"    
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  
  root_block_device {
    volume_size = "28"
  }
  
  tags = {
    Name = "Cluster_Server"
  }
}
### eks-main.tf
resource "aws_iam_role" "eks_cluster_role" {
  name = "CorporateProject-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CorporateProject-cluster-sg"
  }
}

resource "aws_security_group" "eks_node_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CorporateProject-node-sg"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "CorporateProject-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
}

resource "aws_iam_role" "eks_node_role" {
  name = "CorporateProject-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  count      = length(var.node_policy_arns)
  role       = aws_iam_role.eks_node_role.name
  policy_arn = var.node_policy_arns[count.index]
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "CorporateProject-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.micro"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.eks_node_sg.id]
  }
}
