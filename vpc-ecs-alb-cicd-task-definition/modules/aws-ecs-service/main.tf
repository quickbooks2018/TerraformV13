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
}