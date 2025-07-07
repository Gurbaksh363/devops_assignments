resource "aws_ecs_task_definition" "lucy_frontend" {
  family                   = "lucy_frontend_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/taskdef.tpl", {
    alb_dns   = aws_alb.lucy_alb.dns_name
    image_url = "${aws_ecr_repository.lucy-frontend-ecr.repository_url}:latest"
  })
}


resource "aws_ecs_task_definition" "lucy_backend" {
  family                   = "lucy_backend_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "lucy_backend"
    image     = "${aws_ecr_repository.lucy-backend-ecr.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
      protocol      = "tcp"
    }]
  }])
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "role-name"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "lucy_cluster" {
  name = "lucy_cluster"
}

resource "aws_ecs_service" "lucy_frontend_service" {
  name            = "lucy_frontend_service"
  cluster         = aws_ecs_cluster.lucy_cluster.id
  task_definition = aws_ecs_task_definition.lucy_frontend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [
      aws_subnet.lucy_frontend_subnet_1.id,
      aws_subnet.lucy_frontend_subnet_2.id
    ]
    security_groups = [aws_security_group.lucy_frontend_SG.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.lucy_frontend_tg.arn
    container_name   = "lucy_frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_alb_listener.lucy_frontend_listener
  ]
}

resource "aws_ecs_service" "lucy_backend_service" {
  name            = "lucy_backend_service"
  cluster         = aws_ecs_cluster.lucy_cluster.id
  task_definition = aws_ecs_task_definition.lucy_backend.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [
      aws_subnet.lucy_backend_subnet_1.id,
      aws_subnet.lucy_backend_subnet_2.id
    ]
    security_groups = [aws_security_group.lucy_backend_SG.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.lucy_backend_tg.arn
    container_name   = "lucy_backend"
    container_port   = 5000
  }

  depends_on = [
    aws_alb_listener.lucy_backend_listener
  ]
}
