module infrastructure {
  source = "./modules/"

  ##############################################################
  # General
  ##############################################################
  project = "sign-now-testing"
  env = "dev"
  region = "eu-west-1"
  tags = {
    Environment = "dev"
  }

  ##############################################################
  # VPC
  ##############################################################
  vpc_cidr = "10.0.0.0/16"
  num_zones = 2
  single_nat_gateway = true
  enable_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
  one_nat_gateway_per_az = true

  # VPC Tags
  vpc_tags = {
    Environment = "dev"
    Name        = "sign-now-vpc"
  }

  public_subnet_tags = {
    Environment = "dev"
    Type        = "public"
  }

  private_subnet_tags = {
    Environment = "dev"
    Type        = "private"
  }

  domain_name = "sign-now.io"

  ##############################################################
  # ECS
  ##############################################################
  cluster_name = "sign-now-cluster"
  cluster_tags = {
    Environment = "dev"
  }

  ##############################################################
  # Service
  ##############################################################
  delivery_stream = "sign-now-logs"

  # Container configurations
  container_configs = {
    nginx = {
      name   = "nginx"
      image  = "nginx:latest"
      port   = 80
      cpu    = 256
      memory = 512
      environment = {
        "NGINX_SERVER_NAME" = "sign-now.io"
        "NGINX_ROOT"        = "/usr/share/nginx/html"
      }
      capabilities_add = []
      capabilities_drop = ["NET_RAW"]
      memory_reservation = 100
      health_check = {
        path                = "/"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout            = 5
        interval           = 30
        matcher            = "200"
      }
      service_tag = "nginx-service"
    }
    api = {
      name   = "api"
      image  = "your-api-image:latest"
      port   = 3000
      cpu    = 512
      memory = 1024
      environment = {
        "API_KEY" = "your-api-key"
        "DB_URL"  = "your-db-url"
      }
      capabilities_add = []
      capabilities_drop = ["NET_RAW"]
      memory_reservation = 256
      health_check = {
        path                = "/health"
        healthy_threshold   = 3
        unhealthy_threshold = 2
        timeout            = 10
        interval           = 15
        matcher            = "200-399"
      }
      service_tag = "api-service"
    }
  }

  ##############################################################
  # ECR
  ##############################################################
  create_ecr = true
  registry_name = "sign-now-registry"
  registry_tags = {
    Environment = "dev"
  }
}