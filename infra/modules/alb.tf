module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${var.env}-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Create a listener for each container
  listeners = {
    for key, config in var.container_configs : "${var.env}-${key}" => {
      port     = config.port
      protocol = "HTTP"

      forward = {
        target_group_key = "${var.env}_ecs_${key}"
      }
    }
  }

  target_groups = {
    for key, config in var.container_configs : "${var.env}_ecs_${key}" => {
      backend_protocol                  = "HTTP"
      backend_port                      = config.port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = config.health_check.healthy_threshold
        interval            = config.health_check.interval
        matcher             = config.health_check.matcher
        path                = config.health_check.path
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = config.health_check.timeout
        unhealthy_threshold = config.health_check.unhealthy_threshold
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = var.tags

  depends_on = [module.ecs]
}