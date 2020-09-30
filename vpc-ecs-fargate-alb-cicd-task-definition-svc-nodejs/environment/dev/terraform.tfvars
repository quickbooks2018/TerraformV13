# ECS Task Definition & Container Definition
# Task Definition
task-definition-name   = "cloudgeeks-nodejs"
task-definition-cpu    = 1024
task-definition-memory = 2048

# Container Definition
container-name         = "cloudgeeks-nodejs"
repository-uri         = "quickbooks2018/nodejs:v1"
fargate-container-port = 8080

# Cloud Watch Logs
cloudwatch-group        = "/ecs/quickbooks2018"
aws-region              = "us-east-1"
log-stream-prefix       = "nodejs"