# creating vpc
resource "aws_vpc" "lucy_VPC" {
  cidr_block = "10.10.0.0/16"
}

# creating 4 subnets - 2 frontend and 2 backend
resource "aws_subnet" "lucy_frontend_subnet_1" {
  vpc_id     = aws_vpc.lucy_VPC.id
  cidr_block = "10.10.1.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true

  tags = {
    Name = "lucy_frontend_subnet_1"
  }
}
resource "aws_subnet" "lucy_frontend_subnet_2" {
  vpc_id     = aws_vpc.lucy_VPC.id
  cidr_block = "10.10.2.0/24"
   availability_zone = "ap-south-1b"
   map_public_ip_on_launch = true

  tags = {
    Name = "lucy_frontend_subnet_2"
  }
}
resource "aws_subnet" "lucy_backend_subnet_1" {
  vpc_id     = aws_vpc.lucy_VPC.id
  cidr_block = "10.10.3.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true

  tags = {
    Name = "lucy_backend_subnet_1"
  }
}
resource "aws_subnet" "lucy_backend_subnet_2" {
  vpc_id     = aws_vpc.lucy_VPC.id
  cidr_block = "10.10.4.0/24"
   availability_zone = "ap-south-1b"
   map_public_ip_on_launch = true

  tags = {
    Name = "lucy_backend_subnet_2"
  }
}
# creating a internet gateway of vpc
resource "aws_internet_gateway" "lucy_igw" {
  vpc_id = aws_vpc.lucy_VPC.id

  tags = {
    Name = "lucy_igw"
  }
}

# creating route table for 'VPC' and linking it with igw
resource "aws_route_table" "lucy_routetable" {
  vpc_id = aws_vpc.lucy_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lucy_igw.id
  }

  tags = {
    Name = "lucy_routetable"
  }
}
# route table + 4 subnet linking
resource "aws_route_table_association" "my-rt-association-f1" {
  subnet_id      = aws_subnet.lucy_frontend_subnet_1.id
  route_table_id = aws_route_table.lucy_routetable.id
}
resource "aws_route_table_association" "my-rt-association-f2" {
  subnet_id      = aws_subnet.lucy_frontend_subnet_2.id
  route_table_id = aws_route_table.lucy_routetable.id
}
resource "aws_route_table_association" "my-rt-association-b1" {
  subnet_id      = aws_subnet.lucy_backend_subnet_1.id
  route_table_id = aws_route_table.lucy_routetable.id
}
resource "aws_route_table_association" "my-rt-association-b2" {
  subnet_id      = aws_subnet.lucy_backend_subnet_2.id
  route_table_id = aws_route_table.lucy_routetable.id
}

# 1 security group for frontend as well as  backend
resource "aws_security_group" "lucy_frontend_SG" {
  name        = "lucy_frontend_SG"
  vpc_id      = aws_vpc.lucy_VPC.id

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    security_groups = [aws_security_group.lucy_alb_sg.id] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "lucy_frontend_SG"
  }
}
resource "aws_security_group" "lucy_backend_SG" {
  name        = "lucy_backend_SG"
  vpc_id      = aws_vpc.lucy_VPC.id

  ingress {
    from_port        = 5000
    to_port          = 5000
    protocol         = "tcp"
    security_groups = [aws_security_group.lucy_alb_sg.id] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "lucy_backend_SG"
  }
}