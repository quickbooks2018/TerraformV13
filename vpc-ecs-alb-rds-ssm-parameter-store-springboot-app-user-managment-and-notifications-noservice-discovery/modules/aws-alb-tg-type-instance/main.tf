resource "aws_lb_target_group" "alb-tg" {
  name     = var.alb-tg-name
  port     = var.target-group-port
  protocol = var.target-group-protocol
  vpc_id   = var.vpc-id
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

