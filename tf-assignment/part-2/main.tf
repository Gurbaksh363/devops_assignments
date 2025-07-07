terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
} 
provider "aws" {
  region = "ap-south-1"
    access_key = var.access_key
    secret_key = var.secret_key
}
# vpc
resource "aws_vpc" "lucifer_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    project = "lucifer"
  }
}
# subnet
resource "aws_subnet" "lucifer_subnet" {
  vpc_id            = aws_vpc.lucifer_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true # instances will get public ip automatically

  tags = {
    project = "lucifer"
  }
}

resource "aws_internet_gateway" "lucifer_igw" {
  vpc_id = aws_vpc.lucifer_vpc.id
  
  tags = {
    Name = "lucifer-igw"
    project = "lucifer"
  }
}
resource "aws_route_table" "lucifer_rt" {
  vpc_id = aws_vpc.lucifer_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lucifer_igw.id
  }
  
  tags = {
    Name = "lucifer-route-table"
    project = "lucifer"
  }
}

resource "aws_route_table_association" "lucifer_subnet_association" {
  subnet_id = aws_subnet.lucifer_subnet.id
  route_table_id = aws_route_table.lucifer_rt.id
}
# security_group
resource "aws_security_group" "lucifer_frontend_sg" {
  name        = "lucifer_frontend_sg"
  description = "Allows frontend traffic on lucifer"
  vpc_id      = aws_vpc.lucifer_vpc.id

  tags = {
    name = "lucifer_frontend_sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "lucifer_frontend_sg_ipv4_ssh" {
  security_group_id = aws_security_group.lucifer_frontend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_ingress_rule" "lucifer_frontend_sg_ipv4_http" {
  security_group_id = aws_security_group.lucifer_frontend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_frontend" {
  security_group_id = aws_security_group.lucifer_frontend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_security_group" "lucifer_backend_sg" {
  name        = "lucifer_backend_sg"
  description = "Allows backend traffic on lucifer"
  vpc_id      = aws_vpc.lucifer_vpc.id

  tags = {
    name = "lucifer_backend_sg"
  }
}
resource "aws_vpc_security_group_ingress_rule" "lucifer_backend_sg_ipv4_ssh" {
  security_group_id = aws_security_group.lucifer_backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "lucifer_backend_sg_ipv4_flask" {
  security_group_id = aws_security_group.lucifer_backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_backend" {
  security_group_id = aws_security_group.lucifer_backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_instance" "lucifer_frontend_instance" {
  ami           = "ami-02521d90e7410d9f0"
  instance_type = "t2.micro"
  key_name                    = "selene-tf"
  vpc_security_group_ids = [aws_security_group.lucifer_frontend_sg.id]
  subnet_id = aws_subnet.lucifer_subnet.id
  associate_public_ip_address = true
   depends_on = [aws_instance.lucifer_backend_instance]
  # user_data                   = file("./frontend_init.yaml")   # cloud-init executed during creation of ec2 engine first thing


  provisioner "file" {          # uploading required documents
    source      = "./frontend.zip"
    destination = "/home/ubuntu/frontend.zip"
  }
  connection {                
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./selene-tf.pem")    
    host     = self.public_ip
  }

  provisioner "remote-exec" {        
    inline = [
      "#!/bin/bash",
      "sudo apt update -y",
      "sudo apt install -y nodejs zip unzip npm",
      "cd /home/ubuntu",
      "unzip frontend.zip",
      "cd frontend",
      "echo 'BACKEND_URL=http://${aws_instance.lucifer_backend_instance.public_ip}:5000' | sudo tee -a /etc/environment",
      "npm install",
      "source /etc/environment && nohup npm start > frontend.log 2>&1 &",

    ]
  }

  # network_interface {
  #   network_interface_id = aws_network_interface.lucifer_frontend_ni.id
  #   device_index         = 0
  # }
  
  tags = {
    name = "lucifer-frontend"
  }
}

resource "aws_instance" "lucifer_backend_instance" {
  ami           =  "ami-02521d90e7410d9f0"
  instance_type = "t2.micro"
  key_name                    = "selene-tf"
  vpc_security_group_ids = [aws_security_group.lucifer_backend_sg.id]
  subnet_id = aws_subnet.lucifer_subnet.id
  associate_public_ip_address = true
  # user_data                   = file("./backend_init.yaml")   # cloud-init executed during creation of ec2 engine first thing

  provisioner "file" {          # uploading required documents
    source      = "./backend.zip"
    destination = "/home/ubuntu/backend.zip"
  }
  connection {                
    type     = "ssh"
    user     = "ubuntu"
    private_key = file("./selene-tf.pem")    
    host     = self.public_ip
  }

  provisioner "remote-exec" {        
    inline = [
      "#!/bin/bash",
      # "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",   # Mahhan line... we are waiting till the system is updated properly
      "sudo apt update -y", 
      "sudo apt install -y python3 python3-pip python3-venv unzip",
      "cd /home/ubuntu",
      "unzip backend.zip",
      "cd backend",
      "python3 -m venv venv",
      "source venv/bin/activate",
      "pip3 install -r requirements.txt", 
      "nohup python3 app.py > backend.log 2>&1 &",
    ]
  }

  # network_interface {
  #   network_interface_id = aws_network_interface.lucifer_backend_ni.id
  #   device_index         = 0
  # }
  
  tags = {
    name = "lucifer-backend"
  }
}

