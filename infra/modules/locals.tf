locals {
  # Calculate container CPU and memory based on container configs
  container_cpu_memory = {
    for key, config in var.container_configs : key => {
      cpu    = max(256, config.cpu)
      memory = max(512, config.memory)
    }
  }

  # Calculate container memory reservation based on container configs
  container_memory_reservation = {
    for key, config in var.container_configs : key => max(128, config.memory_reservation)
  }

  # Calculate container capabilities based on container configs
  container_capabilities = {
    for key, config in var.container_configs : key => {
      add  = length(config.capabilities_add) > 0 ? config.capabilities_add : []
      drop = length(config.capabilities_drop) > 0 ? config.capabilities_drop : ["MKNOD"]
    }
  }

  # Calculate service tags based on container configs
  service_tags = {
    for key, config in var.container_configs : key => config.service_tag != "" ? config.service_tag : key
  }

  # Calculate health check settings based on container configs
  health_check_settings = {
    for key, config in var.container_configs : key => {
      path                = config.health_check.path
      healthy_threshold   = config.health_check.healthy_threshold
      unhealthy_threshold = config.health_check.unhealthy_threshold
      timeout            = config.health_check.timeout
      interval           = config.health_check.interval
      matcher            = config.health_check.matcher
    }
  }

  # Calculate container environment variables based on container configs
  container_environment = {
    for key, config in var.container_configs : key => [
      for env_key, env_value in config.environment : {
        name  = env_key
        value = env_value
      }
    ]
  }

  # Calculate container port mappings based on container configs
  container_port_mappings = {
    for key, config in var.container_configs : key => [
      {
        name          = config.name
        containerPort = config.port
        hostPort      = config.port
        protocol      = "tcp"
      }
    ]
  }

  # Calculate container dependencies based on container configs
  container_dependencies = {
    for key, config in var.container_configs : key => [
      {
        containerName = "fluent-bit"
        condition     = "START"
      }
    ]
  }

  # Calculate container log configuration based on container configs
  container_log_configuration = {
    for key, config in var.container_configs : key => {
      logDriver = "awsfirelens"
      options = {
        Name                    = "firehose"
        region                  = var.region
        delivery_stream         = "${var.delivery_stream}-${var.env}"
        log-driver-buffer-limit = "2097152"
      }
    }
  }

  # Calculate container linux parameters based on container configs
  container_linux_parameters = {
    for key, config in var.container_configs : key => {
      capabilities = {
        add  = local.container_capabilities[key].add
        drop = local.container_capabilities[key].drop
      }
    }
  }

  # Calculate total CPU and memory needed for the task
  task_cpu_memory = {
    for key, config in var.container_configs : key => {
      # Total CPU = fluent-bit CPU (256) + container CPU
      cpu = 256 + local.container_cpu_memory[key].cpu
      # Total memory = fluent-bit memory (512) + container memory + FireLens buffer (50MB)
      memory = 512 + local.container_cpu_memory[key].memory + 50
    }
  }
}

