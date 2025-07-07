[
  {
    "name": "lucy_frontend",
    "image": "${image_url}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "BACKEND_URL",
        "value": "http://${alb_dns}:5000"
      }
    ]
  }
]
