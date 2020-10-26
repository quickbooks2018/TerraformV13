# ECS Task Definition & Container Definition
# Task Definition
task-definition-name   = "aws-codepipeline"
task-definition-cpu    = 1024
task-definition-memory = 2048

# Container Definition
container-name         = "aws-codepipeline"
repository-uri         = "quickbooks2018/blue"
fargate-container-port = 80

# Cloud Watch Logs
cloudwatch-group        = "/ecs/quickbooks2018"
aws-region              = "us-east-1"
log-stream-prefix       = "path-blue"