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
resource "aws_vpc" "CorporateProject_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CorporateProject-vpc"
  }
}

resource "aws_subnet" "CorporateProject_subnet" {
  count = 2
  vpc_id                  = aws_vpc.CorporateProject_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.CorporateProject_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "CorporateProject-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "CorporateProject_igw" {
  vpc_id = aws_vpc.CorporateProject_vpc.id

  tags = {
    Name = "CorporateProject-igw"
  }
}

resource "aws_route_table" "CorporateProject_route_table" {
  vpc_id = aws_vpc.CorporateProject_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.CorporateProject_igw.id
  }

  tags = {
    Name = "CorporateProject-route-table"
  }
}

resource "aws_route_table_association" "CorporateProject_association" {
  count          = 2
  subnet_id      = aws_subnet.CorporateProject_subnet[count.index].id
  route_table_id = aws_route_table.CorporateProject_route_table.id
}

resource "aws_security_group" "CorporateProject_cluster_sg" {
  vpc_id = aws_vpc.CorporateProject_vpc.id

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

resource "aws_security_group" "CorporateProject_node_sg" {
  vpc_id = aws_vpc.CorporateProject_vpc.id

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

resource "aws_eks_cluster" "CorporateProject" {
  name     = "CorporateProject-cluster"
  role_arn = aws_iam_role.CorporateProject_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.CorporateProject_subnet[*].id
    security_group_ids = [aws_security_group.CorporateProject_cluster_sg.id]
  }
}

resource "aws_eks_node_group" "CorporateProject" {
  cluster_name    = aws_eks_cluster.CorporateProject.name
  node_group_name = "CorporateProject-node-group"
  node_role_arn   = aws_iam_role.CorporateProject_node_group_role.arn
  subnet_ids      = aws_subnet.CorporateProject_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.CorporateProject_node_sg.id]
  }
}

resource "aws_iam_role" "CorporateProject_cluster_role" {
  name = "CorporateProject-cluster-role"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "CorporateProject_cluster_role_policy" {
  role       = aws_iam_role.CorporateProject_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "CorporateProject_node_group_role" {
  name = "CorporateProject-node-group-role"

  assume_role_policy = <<EOF
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
EOF
}
# Create a subnet group for the RDS instance
resource "aws_db_subnet_group" "CorporateProject_db_subnet_group" {
  name       = "corporateproject-db-subnet-group"
  subnet_ids = aws_subnet.CorporateProject_subnet[*].id

  tags = {
    Name = "CorporateProject DB Subnet Group"
  }
}

# Security group for RDS allowing MySQL access
resource "aws_security_group" "CorporateProject_rds_sg" {
  name        = "corporateproject-rds-sg"
  description = "Allow MySQL access"
  vpc_id      = aws_vpc.CorporateProject_vpc.id

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust as needed for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CorporateProject RDS SG"
  }
}

# RDS MySQL instance
resource "aws_db_instance" "CorporateProject_mysql" {
  identifier             = "corporateproject-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t2.medium"
  allocated_storage      = 20
  storage_type           = "gp2"
  name                   = "corporateprojectdb"
  username               = "admin"
  password               = "StrongPassword123!" # Replace with a secure password
  db_subnet_group_name   = aws_db_subnet_group.CorporateProject_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.CorporateProject_rds_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name = "CorporateProject MySQL DB"
  }
}

resource "aws_iam_role_policy_attachment" "CorporateProject_node_group_role_policy" {
  role       = aws_iam_role.CorporateProject_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "CorporateProject_node_group_cni_policy" {
  role       = aws_iam_role.CorporateProject_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "CorporateProject_node_group_registry_policy" {
  role       = aws_iam_role.CorporateProject_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
