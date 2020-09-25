# ECS Task Definition & Container Definition
# Task Definition
task-definition-name   = "ecs-springboot-rds-secrets-manager"
task-definition-cpu    = 1024
task-definition-memory = 2048

# Container Definition
container-name         = "ecs-springboot-rds-secrets-manager"
repository-uri         = "quickbooks2018/spring-boot-secret-manager-rds-mysql-access"
fargate-container-port = 80

# Cloud Watch Logs
cloudwatch-group        = "/ecs/quickbooks2018"
aws-region              = "us-east-1"
log-stream-prefix       = "ecs-springboot-rds-secrets-manager"