# ECS Task Definition & Container Definition
# Task Definition
task-definition-name   = "spring-boot-aws-secrets-manager"
task-definition-cpu    = 1024
task-definition-memory = 2048

# Container Definition
container-name         = "ecs-spring-boot-aws-secrets-manager"
repository-uri         = "quickbooks2018/ecs-springboot-app-port-80:latest"
fargate-container-port = 80

# Cloud Watch Logs
cloudwatch-group        = "/ecs/quickbooks2018"
aws-region              = "us-east-1"
log-stream-prefix       = "ecs-spring-boot-aws-secrets-manager"