resource "aws_lb" "alb" {
  name               = var.alb-name
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [var.alb-sg]
  subnets            = var.alb-subnets

  enable_deletion_protection = "true"


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

