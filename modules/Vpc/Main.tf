provider "aws" {
  region = "ap-south-1"
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
