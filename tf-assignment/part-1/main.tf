# telling reqd. providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# configuring aws provider
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# creating a custom sec gp.
resource "aws_security_group" "selene-sg" {
  name        = "selene-sg"

  tags = {
    Name = "selene-sg"
  }
}
# adding ingress and egress rules
resource "aws_vpc_security_group_ingress_rule" "allow_selene_sg1" {
  security_group_id = aws_security_group.selene-sg.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_selene_sg2" {
  security_group_id = aws_security_group.selene-sg.id
  cidr_ipv4         ="0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_selene_sg3" {
  security_group_id = aws_security_group.selene-sg.id
  cidr_ipv4        = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_selene_sg5" {    # without egress rule it was unable to make request outside and download reqd resources
  security_group_id = aws_security_group.selene-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# creating ec2 instance
resource "aws_instance" "selene" {
  ami                         = "ami-02521d90e7410d9f0"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  key_name                    = "selene-tf"
  user_data                   = file("./cloud-init.yaml")   # cloud-init executed during creation of ec2 engine first thing
  vpc_security_group_ids = [aws_security_group.selene-sg.id]

  provisioner "file" {          # uploading required documents
    source      = "./microservice.zip"
    destination = "/home/ubuntu/microservice.zip"
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
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do sleep 1; done",   # Mahhan line... we are waiting till the system is updated properly
      "cd /home/ubuntu",
      "unzip microservice.zip",
      "cd backend",
      "python3 -m venv venv",
      "source venv/bin/activate",            # if u don't mention #!/bin/bash it will use bin/sh and 'source' does not exist there we use .
      "pip3 install -r requirements.txt",
      "nohup python3 app.py > backend.log 2>&1 &",
      "cd ../frontend",
      "npm install",
      "nohup npm start > backend.log 2>&1 &",
    ]
  }

  tags = {
    Name = "selene"
  }
}
