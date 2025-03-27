###############################################################################
# Route53 Zone
###############################################################################
resource "aws_route53_zone" "main" {
  name = var.domain_name

  force_destroy = true
}

###############################################################################
# Route53 Records
###############################################################################
resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"  # Changed to A record for alias

  alias {
    name                   = data.aws_alb.alb.dns_name
    zone_id               = data.aws_alb.alb.zone_id
    evaluate_target_health = true
  }

  depends_on = [module.alb, data.aws_alb.alb]
}

data "aws_alb" "alb" {
  name = "${var.env}-alb"
  depends_on = [time_sleep.alb_loading_delay]
}

resource "time_sleep" "alb_loading_delay" {
  depends_on = [
    module.alb,
  ]

  destroy_duration = "60s"   
}

###############################################################################
# ACM
###############################################################################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain_name
  zone_id    = aws_route53_zone.main.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.domain_name}",
  ]

  wait_for_validation = false

  tags = {
    Name        = var.domain_name
    Environment = var.env
    Terraform   = "true"
  }

  depends_on = [aws_route53_zone.main, module.alb]
}