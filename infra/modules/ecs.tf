################################################################################
# ECS Cluster
################################################################################

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = var.cluster_name

  # Capacity provider
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 20
        base   = 1
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 80
      }
    }
  }

  tags = var.tags
  depends_on = [module.vpc]
}

################################################################################
# Service
################################################################################

module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  for_each = var.container_configs

  name        = "${var.env}-${each.key}"
  cluster_arn = module.ecs.cluster_arn

  # Use the total CPU and memory needed for the task
  cpu    = local.task_cpu_memory[each.key].cpu
  memory = local.task_cpu_memory[each.key].memory

  # Enables ECS Exec
  enable_execute_command = true

  # Container definition(s)
  container_definitions = {
    fluent-bit = {
      cpu       = 256
      memory    = 512
      essential = true
      image     = nonsensitive(data.aws_ssm_parameter.fluentbit.value)
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
      user               = "0"
    }

    (each.value.name) = {
      cpu       = local.container_cpu_memory[each.key].cpu
      memory    = local.container_cpu_memory[each.key].memory
      essential = true
      image     = each.value.image
      port_mappings = local.container_port_mappings[each.key]

      environment = local.container_environment[each.key]

      readonly_root_filesystem = false

      dependencies = local.container_dependencies[each.key]

      enable_cloudwatch_logging = false
      log_configuration = local.container_log_configuration[each.key]

      linux_parameters = local.container_linux_parameters[each.key]

      memory_reservation = local.container_memory_reservation[each.key]
    }
  }

  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      client_alias = {
        port     = each.value.port
        dns_name = each.value.name
      }
      port_name      = each.value.name
      discovery_name = each.value.name
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups["${var.env}_ecs_${each.key}"].arn
      container_name   = each.value.name
      container_port   = each.value.port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = each.value.port
      to_port                  = each.value.port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  service_tags = {
    "ServiceTag" = local.service_tags[each.key]
  }

  tags = merge(var.tags, {
    Service = each.key
  })
  depends_on = [module.alb]
}