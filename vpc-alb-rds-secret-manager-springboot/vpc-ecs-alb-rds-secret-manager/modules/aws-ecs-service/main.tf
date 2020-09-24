resource "aws_ecs_service" "aws-ecs-service" {
  name                                     = var.aws-ecs-service-name
  cluster                                  = var.ecs-cluster-id
  deployment_minimum_healthy_percent       = var.deployment-minimum-healthy-percent
  deployment_maximum_percent               = var.deployment-maximum-percent
  task_definition                          = var.task-definition
  desired_count                            = var.desired-count
  health_check_grace_period_seconds        = var.health-check-grace-period-seconds


  load_balancer {
    target_group_arn  = var.target-group-arn
    container_name    = var.container-name
    container_port    = var.container-port
  }
  network_configuration {
    security_groups  = var.security-groups
    subnets          = var.private-subnets
    assign_public_ip = var.assign-public-ip
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [desired_count]
  }

}

# Auto Scaling
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.max-capacity
  min_capacity       = var.min-capacity
  resource_id        = "service/${var.aws-ecscluster-name}/${var.aws-ecs-service-name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  depends_on = [aws_ecs_service.aws-ecs-service]

}



# CPU Utilization
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  name               = "cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    target_value       = var.cpu-exceeds-percentage
  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Memory Utilization
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  name               = "memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    target_value       = var.memory-exceeds-percentage

  }
  depends_on = [aws_appautoscaling_target.ecs_target]
}
