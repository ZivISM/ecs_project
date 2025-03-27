##################################################
# GENERAL
##################################################
variable "project" {
  type = string
  description = "The project name"
}

variable "env" {
  type = string
  description = "The environment to deploy into"
}

variable "region" {
  type = string
  description = "The region to deploy into"
}

variable "tags" {
  description = "The tags to deploy into"
  type        = map(string)
}

##################################################
# NETWORK
##################################################

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "num_zones" {
  description = "The number of availability zones to use"
  type        = number
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT gateway"
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to enable NAT gateways"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether to enable DNS hostnames"
  type        = bool
}

variable "enable_dns_support" {
  description = "Whether to enable DNS support"
  type        = bool
}

variable "one_nat_gateway_per_az" {
  description = "Whether to enable one NAT gateway per availability zone"
  type        = bool
}

variable "public_subnet_tags" {
  description = "The tags for the public subnets"
  type        = map(string)
}

variable "private_subnet_tags" {
  description = "The tags for the private subnets"
  type        = map(string)
}

variable "vpc_tags" {
  description = "The tags for the VPC"
  type        = map(string)
}

variable "domain_name" {
  description = "The domain name to use"
  type        = string
}

##################################################
# ECS
##################################################

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "cluster_tags" {
  description = "The tags for the ECS cluster"
  type        = map(string)
}

##################################################
# CONTAINER/SERVICE
##################################################
variable "delivery_stream" {
  description = "The delivery stream for the service {keeping logs}"
  type        = string
}

variable "container_configs" {
  description = "Map of container configurations for different containers"
  type = map(object({
    name        = string
    image       = string
    port        = number
    cpu         = number
    memory      = number
    environment = optional(map(string), {})
    service_tag = optional(string, "")
    capabilities_add = optional(list(string), [])
    capabilities_drop = optional(list(string), [])
    memory_reservation = optional(number, 0)
    health_check = optional(object({
      path                = string
      healthy_threshold   = optional(number, 5)
      unhealthy_threshold = optional(number, 2)
      timeout            = optional(number, 5)
      interval           = optional(number, 30)
      matcher            = optional(string, "200")
    }), {
      path                = "/"
      healthy_threshold   = 5
      unhealthy_threshold = 2
      timeout            = 5
      interval           = 30
      matcher            = "200"
    })
  }))
  default = {}
}

##################################################
# ECR
##################################################

variable "create_ecr" {
  description = "Whether to create an ECR registry"
  type        = bool
}

variable "registry_name" {
  description = "The name of the ECR registry"
  type        = string
}

variable "registry_tags" {
  description = "The tags for the ECR registry"
  type        = map(string)
}
