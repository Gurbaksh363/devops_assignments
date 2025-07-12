# 🚀 DevOps Assignments

This repository contains various DevOps assignments demonstrating different technologies and practices including containerization, Kubernetes orchestration, CI/CD pipelines, and Infrastructure as Code (IaC) with Terraform.

## 📁 Project Structure

### 1️⃣ docker_k8_assignment - Basic Flask App with Docker & Kubernetes 🐍
A simple Flask web application that displays environment variables with Docker containerization and Kubernetes deployment.

**What it demonstrates:** ✨
- 🌐 Basic Flask web application
- 🐳 Docker containerization with Alpine Linux
- ☸️ Kubernetes deployment and service configuration
- 🔧 Environment variable handling in containers

**Key files:** 📂
- `app.py` - Flask application that renders environment variables
- `Dockerfile` - Multi-stage Docker build with Python Alpine
- `k8/deployment.yaml` - Kubernetes deployment with 3 replicas
- `k8/service.yaml` - Kubernetes service configuration


### 2️⃣ k8_assignment - Kubernetes Orchestration ☸️
Advanced Kubernetes deployment with proper container orchestration for microservices architecture.

**What it demonstrates:** ✨
- 🎯 Container orchestration with Kubernetes
- 🔍 Service discovery between microservices
- ⚙️ Environment-specific configuration
- 📦 Multi-container application deployment

**Components:** 🧩
- **Backend**: Flask API with Dockerfile
- **Frontend**: Node.js app with Dockerfile
- **k8/**: Kubernetes manifests for both services with proper networking

### 3️⃣ tf-assignment - Terraform Infrastructure as Code 🏗️
Infrastructure automation using Terraform across multiple cloud scenarios.

**What it demonstrates:** ✨
- 📋 Infrastructure as Code (IaC) practices
- 🔄 Multi-part infrastructure deployment
- ☁️ Cloud-init for server configuration
- ⚖️ Load balancing and container orchestration

**Parts:** 📦
- **part-1/**: Basic infrastructure with cloud-init setup
- **part-2/**: Advanced infrastructure with separate backend/frontend initialization
- **part-3/**: Complete AWS infrastructure with ALB, ECR, ECS, and VPC

### 4️⃣ cicd-assignment - Full-Stack Application with Backend/Frontend 🔄
A complete web application with Node.js frontend and Python Flask backend, designed for CI/CD pipeline implementation.

**What it demonstrates:** ✨
- 🏗️ Microservices architecture (frontend/backend separation)
- 🔗 RESTful API communication
- 🍃 MongoDB integration
- 📝 Form handling and data persistence

**Components:** 🧩
- **Backend** (`backend/`): Flask API with MongoDB connection for user registration
- **Frontend** (`frontend/`): Express.js server with EJS templating for signup forms

## 🚀 Getting Started

### Prerequisites 📋
- Docker
- Kubernetes (kubectl)
- Terraform
- Python 3.x
- Node.js
- MongoDB (for full-stack applications)

### Running Individual Projects

#### 1️⃣ docker_k8_assignment/ - Basic Flask App 🐍
```bash
cd docker_k8_assignment/
docker build -t flask-app .
docker run -p 8000:8000 flask-app
```

#### 2️⃣ k8_assignment/ - Kubernetes Deployment ☸️
```bash
cd k8_assignment/k8/
kubectl apply -f backend.yaml
kubectl apply -f frontend.yaml
```

#### 3️⃣ tf-assignment/ - Terraform Infrastructure 🏗️
```bash
cd tf-assignment/part-1/
terraform init
terraform plan
terraform apply
```

#### 4️⃣ cicd-assignment/ - Full-Stack App 🔄
```bash
# Backend
cd cicd-assignment/backend/
pip install -r requirements.txt
python app.py

# Frontend (in another terminal)
cd cicd-assignment/frontend/
npm install
npm start
```

## Technologies Used

- **Containerization**: Docker
- **Orchestration**: Kubernetes
- **Backend**: Python Flask, MongoDB
- **Frontend**: Node.js, Express.js, EJS
- **Infrastructure**: Terraform, AWS (ALB, ECR, ECS, VPC)
- **Configuration**: YAML, cloud-init

## Learning Objectives

1. **Containerization**: Understanding Docker fundamentals and best practices
2. **Orchestration**: Kubernetes deployment, services, and networking
3. **Microservices**: Building and connecting distributed applications
4. **Infrastructure as Code**: Automating cloud infrastructure with Terraform
5. **DevOps Practices**: Integration of development and operations workflows

## Notes

- All applications use environment variables for configuration
- Docker images are published to `docker.io/gurbakshkaur/`
- Kubernetes configurations assume proper cluster setup
- Terraform configurations target AWS cloud provider
