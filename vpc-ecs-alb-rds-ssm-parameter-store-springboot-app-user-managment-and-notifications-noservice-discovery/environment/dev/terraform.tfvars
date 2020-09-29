# ECS Task Definition & Container Definition
# Task Definition for User Management Service
task-definition-name-user-management-service              = "microservice-user-management"
task-definition-cpu                                      = 1024
task-definition-memory                                   = 2048

# Container Definition for User Management Service
microservice-user-management-container-name              = "microservice-user-management"
microservice-user-management-repository-uri              = "quickbooks2018/microservice-user-management:latest"
microservice-user-management-fargate-container-port      = 8095


# Cloud Watch Logs For User Management Service
cloudwatch-group                                          = "/ecs/quickbooks2018"
aws-region                                                = "us-east-1"
user-management-container-log-stream-prefix               = "microservice-user-management"
