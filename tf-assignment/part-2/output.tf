output "frontend_url" {
  value = "http://${aws_instance.lucifer_frontend_instance.public_ip}:3000"
  description = "URL to access the frontend application"
}

output "backend_url" {
  value = "http://${aws_instance.lucifer_backend_instance.public_ip}:5000"
  description = "URL to access the backend API"
}

