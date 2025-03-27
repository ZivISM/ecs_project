# AWS ECS Infrastructure Project

This repository contains Infrastructure as Code (IaC) for deploying and managing applications on AWS Elastic Container Service (ECS). The infrastructure is defined using Terraform and follows AWS best practices for container orchestration.

## 🏗 Infrastructure Components

The project sets up a complete ECS environment including:

- **VPC Configuration**: A custom VPC with public and private subnets across multiple availability zones
- **ECS Cluster**: Managed container orchestration platform
- **Application Load Balancer (ALB)**: For distributing traffic to containers
- **ECR Repository**: For storing Docker images
- **IAM Roles and Policies**: Secure access control for all components
- **Auto Scaling**: Automatic scaling of container instances based on demand

## 📁 Project Structure

```
.
├── infra/
│   ├── backend.tf          # Terraform backend configuration
│   ├── main.tf            # Main Terraform configuration
│   └── modules/
│       ├── acm.tf         # SSL/TLS certificate management
│       ├── alb.tf         # Application Load Balancer configuration
│       ├── ecr.tf         # Elastic Container Registry setup
│       ├── ecs.tf         # ECS cluster and service definitions
│       ├── iam.tf         # IAM roles and policies
│       ├── locals.tf      # Local variables
│       ├── providers.tf   # AWS provider configuration
│       ├── resources.tf   # Additional AWS resources
│       ├── variables.tf   # Input variables
│       └── vpc.tf         # VPC and networking configuration
└── services/              # Application services directory
```

## 🚀 Getting Started

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0.0
- Docker (for building and pushing container images)

### Initial Setup

1. Configure AWS credentials:
```bash
aws configure
```

2. Initialize Terraform:
```bash
cd infra
terraform init
```

3. Review and apply the infrastructure:
```bash
terraform plan
terraform apply
```

## 🔧 Configuration

The infrastructure can be customized through variables in `infra/modules/variables.tf`. Key configurations include:

- VPC CIDR ranges
- Container specifications
- Auto-scaling parameters
- Load balancer settings
- Region and availability zones

## 🔐 Security

This infrastructure implements several security best practices:

- Private subnets for container workloads
- IAM roles with least privilege access
- Security groups for network access control
- SSL/TLS termination at the load balancer
- Isolated network architecture

## 🏷 Tags and Versioning

All resources are tagged following AWS tagging best practices for better resource management and cost allocation.

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request


## ⚠️ Important Notes

- Remember to destroy resources when not in use to avoid unnecessary costs
- Keep your AWS credentials secure and never commit them to version control
- Regularly update dependencies and AWS provider versions
- Monitor CloudWatch logs and metrics for operational health

## 🤝 Support

For support and questions, please open an issue in the GitHub repository. 