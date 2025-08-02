# Fullstack AWS Deployment: React + Spring Boot + Terraform + Jenkins

This project is a full-stack application deployed on AWS using **Terraform** for infrastructure provisioning and **Jenkins** for CI/CD automation. It includes:

- 🌐 Frontend: React (deployed to S3 + CloudFront)
- 🔧 Backend: Spring Boot (deployed to EC2 or Elastic Beanstalk)
- ☁️ AWS Services: EC2, RDS, S3, CloudFront, IAM, VPC
- 🏗 Infrastructure: Provisioned with Terraform
- 🚀 CI/CD: Jenkins pipeline

---

## 🔧 Tech Stack

| Layer       | Technology                         |
|------------|-------------------------------------|
| Frontend    | React, npm, S3, CloudFront          |
| Backend     | Spring Boot, Maven, EC2             |
| Database    | PostgreSQL / MySQL on RDS           |
| Infra       | Terraform                           |
| CI/CD       | Jenkins, Docker                     |
| Cloud       | AWS (IAM, VPC, S3, EC2, RDS, etc.)  |

---

## 📁 Project Structure

fullstack-aws-terraform/
├── backend/ # Spring Boot app
├── frontend/ # React app
├── terraform/ # Terraform infrastructure code
│ ├── env/dev/ # Environment variables
│ ├── modules/ # Reusable Terraform modules
│ ├── main.tf # Infra entry point
│ ├── outputs.tf # Outputs
│ └── variables.tf # Input variables
├── jenkins/ # Jenkins pipeline and helper scripts
│ ├── Jenkinsfile
│ ├── backend-deploy.groovy
│ ├── frontend-deploy.groovy
├── deploy/ # Manual deploy scripts (optional)
└── README.md

## 🚀 Deployment Flow

### 1. ✅ Infrastructure Provisioning (Terraform)

```bash
cd terraform/env/dev
terraform init
terraform plan
terraform apply
