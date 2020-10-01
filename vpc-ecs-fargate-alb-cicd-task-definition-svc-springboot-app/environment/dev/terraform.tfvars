# ECS Task Definition & Container Definition
# Task Definition
task-definition-name   = "cloudgeeks-springboot"
task-definition-cpu    = 1024
task-definition-memory = 2048

# Container Definition
container-name         = "cloudgeeks-springboot"
repository-uri         = "049043308513.dkr.ecr.us-east-1.amazonaws.com/cloudgeeksinc:cloudgeeksinc-springboot-app-v1"
fargate-container-port = 8080

# Cloud Watch Logs
cloudwatch-group        = "/ecs/quickbooks2018"
aws-region              = "us-east-1"
log-stream-prefix       = "springboot"