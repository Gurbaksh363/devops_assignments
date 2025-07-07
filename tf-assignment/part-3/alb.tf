resource "aws_security_group" "lucy_alb_sg" {
  name   = "lucy_alb_sg"
  vpc_id = aws_vpc.lucy_VPC.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 3000
  to_port     = 3000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lucy_alb_sg"
  }
}
resource "aws_alb" "lucy_alb" {
  name = "lucy-load-balancer"
  subnets = [
    aws_subnet.lucy_frontend_subnet_1.id,
    aws_subnet.lucy_frontend_subnet_2.id,
  ]

  security_groups = [aws_security_group.lucy_alb_sg.id]
}


resource "aws_alb_target_group" "lucy_frontend_tg" {
  name        = "lucy-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lucy_VPC.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}
resource "aws_alb_target_group" "lucy_backend_tg" {
  name        = "lucy-backend-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.lucy_VPC.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Listens all traffic and send  to the target group
resource "aws_alb_listener" "lucy_frontend_listener" {
  load_balancer_arn = aws_alb.lucy_alb.id
  port              = 3000
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.lucy_frontend_tg.id
    type             = "forward"
  }
}
resource "aws_alb_listener" "lucy_backend_listener" {
  load_balancer_arn = aws_alb.lucy_alb.id
  port              = 5000
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.lucy_backend_tg.id
    type             = "forward"
  }
}
