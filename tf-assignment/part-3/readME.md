# Lucy Application - Terraform Infrastructure

This project contains Terraform configuration files to deploy a containerized full-stack application (Lucy) on AWS using ECS Fargate, ECR, and Application Load Balancer.

## Architecture Overview

The infrastructure deploys:
- **Frontend**: React application running on port 3000
- **Backend**: Node.js/Express API running on port 5000
- **Load Balancer**: Application Load Balancer for traffic distribution
- **Container Registry**: ECR repositories for Docker images
- **Networking**: VPC with public subnets across multiple AZs

## AWS Resources Created

- **VPC**: Custom VPC (10.10.0.0/16) with Internet Gateway
- **Subnets**: 4 public subnets across 2 availability zones
  - Frontend subnets: 10.10.1.0/24, 10.10.2.0/24
  - Backend subnets: 10.10.3.0/24, 10.10.4.0/24
- **ECR Repositories**: 
  - lucy-frontend-ecr
  - lucy-backend-ecr
- **ECS Cluster**: Fargate cluster for containerized applications
- **Application Load Balancer**: Routes traffic to frontend (port 3000) and backend (port 5000)
- **Security Groups**: Configured for ALB and application tiers
- **IAM Roles**: ECS task execution roles with required policies

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.12.1 installed
- Docker installed for building and pushing images
- Frontend and Backend application code in respective directories

## Project Structure

```
tf-assignment/
├── part-3/              # Main Terraform configuration
├── frontend/            # Frontend application code (React)
├── backend/             # Backend application code (Node.js)
├── terraform.tfstate    # Terraform state file
└── readME.md           # This file
```

## Deployment Instructions

### 1. Initialize Terraform
```bash
cd part-3
terraform init
```

### 2. Plan Infrastructure
```bash
terraform plan
```

### 3. Deploy Infrastructure
```bash
terraform apply
```

### 4. Access Application
After deployment, access the application using the Load Balancer DNS name:
- **Frontend**: `http://<alb-dns-name>:3000`
- **Backend**: `http://<alb-dns-name>:5000`

The ALB DNS name can be found in the AWS Console or Terraform output.

## Application Details

### Frontend Service
- **Image**: lucy-frontend-ecr:latest
- **Port**: 3000
- **Replicas**: 2
- **Environment**: BACKEND_URL configured to communicate with backend

### Backend Service
- **Image**: lucy-backend-ecr:latest
- **Port**: 5000
- **Replicas**: 2
- **Health Check**: HTTP health check on root path

## Container Images

The Terraform configuration includes null resources that:
1. Authenticate with ECR
2. Build and tag Docker images
3. Push images to respective ECR repositories

Images are automatically built and pushed during `terraform apply`.

## Security Configuration

- **ALB Security Group**: Allows inbound traffic on ports 80, 3000, 5000
- **Frontend Security Group**: Allows traffic from ALB on port 3000
- **Backend Security Group**: Allows traffic from ALB on port 5000
- **ECS Tasks**: Run in public subnets with public IP assignment

## Networking

- **VPC**: 10.10.0.0/16
- **Availability Zones**: ap-south-1a, ap-south-1b
- **Route Table**: Single route table with internet gateway route
- **Load Balancer**: Internet-facing ALB across multiple AZs

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Note**: Ensure ECR repositories are empty before destroying to avoid errors.

## Troubleshooting

### Common Issues:
1. **ECR Authentication**: Ensure AWS CLI is configured with proper permissions
2. **Docker Build**: Verify Dockerfile exists in frontend/backend directories
3. **Health Checks**: Check application responds to health check endpoints
4. **Security Groups**: Verify ports are correctly configured

## Cost Considerations

- **ECS Fargate**: Charges based on vCPU and memory allocation
- **Application Load Balancer**: Hourly charges plus data processing
- **ECR**: Storage charges for container images
- **Data Transfer**: Charges for data transfer between AZs

## Support

For issues or questions regarding this infrastructure setup, please check:
- AWS CloudFormation events for deployment issues
- ECS service logs for application issues
- ALB access logs for traffic analysis
