#resource "null_resource" "alb_exists" {}

resource "aws_lb_target_group" "alb-tg" {
  name                 = var.alb-tg-name
  port                 = var.target-group-port
  protocol             = var.target-group-protocol
  target_type          = var.target-type
  deregistration_delay = var.deregistration_delay
#  depends_on = [null_resource.alb_exists]
  vpc_id      = var.vpc-id
  health_check {
    enabled             = var.health-check
    interval            = var.interval
    path                = var.path
    port                = var.port
    protocol            = var.protocol
    timeout             = var.timeout
    unhealthy_threshold = var.unhealthy-threshold
    matcher             = var.matcher
  }

}

