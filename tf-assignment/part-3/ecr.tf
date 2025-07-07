data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "lucy-frontend-ecr" {
  name                 = "lucy-frontend-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "lucy-backend-ecr" {
  name                 = "lucy-backend-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "null_resource" "ecr_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-south-1.amazonaws.com"
  }
}

resource "null_resource" "push_frontend" {
  provisioner "local-exec" {
    command = <<EOT
      docker build -t lucifer-frontend -f ./frontend/frontend-dockerfile ./frontend
      docker tag lucifer-frontend:latest ${aws_ecr_repository.lucy-frontend-ecr.repository_url}:latest
      docker push ${aws_ecr_repository.lucy-frontend-ecr.repository_url}:latest
    EOT
  }

  depends_on = [
    aws_ecr_repository.lucy-frontend-ecr,
    null_resource.ecr_login
  ]
}

resource "null_resource" "push_backend" {
  provisioner "local-exec" {
    command = <<EOT
      docker build -t lucifer-backend -f ./backend/backend-dockerfile ./backend
      docker tag lucifer-backend:latest ${aws_ecr_repository.lucy-backend-ecr.repository_url}:latest
      docker push ${aws_ecr_repository.lucy-backend-ecr.repository_url}:latest
    EOT
  }

  depends_on = [
    aws_ecr_repository.lucy-backend-ecr,
    null_resource.ecr_login
  ]
}
