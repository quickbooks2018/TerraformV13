resource "aws_lb" "alb" {
  name               = var.alb-name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb-sg]
  subnets            = var.alb-subnets
  enable_deletion_protection = var.enable-deletion-protection



  tags = {
    Name = var.alb-tag
  }
}

resource "aws_alb_listener" "frontend-listner-80" {
  default_action {
    target_group_arn = var.target-group-arn
    type = "forward"
  }
  load_balancer_arn = aws_lb.alb.arn
  port = 80

}

resource "aws_lb_listener_rule" "aws-lb-listener-rule-port-80-path" {
  listener_arn = aws_alb_listener.frontend-listner-80.arn
  priority = 100
  action {
    type = "forward"
    target_group_arn = var.target-group-arn
  }
  condition {
    path_pattern {
      values = [var.rule-path]
    }
  }
}
