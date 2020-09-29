# ECS Task Definition & Container Definition

# Task Definition for User Management Service
task-definition-name-user-management-service              = "microservice-user-management"
# Container Definition for User Management Service
microservice-user-management-container-name              = "microservice-user-management"
microservice-user-management-repository-uri              = "quickbooks2018/microservice-user-management:latest"
microservice-user-management-fargate-container-port      = 8095
# Cloud Watch Logs For User Management Service

user-management-container-log-stream-prefix               = "microservice-user-management"


# Task Definition User Management
task-definition-cpu                                      = 1024
task-definition-memory                                   = 2048


# Cloud Watch Log Group For User Management
cloudwatch-group-svc-user-management                      = "/ecs/quickbooks2018/svc-user-management"
aws-region                                                = "us-east-1"




# Task Definition Notification Service
task-definition-name-notification-service                  = "microservice-notifications"
# Container Definition for Notification Service
microservice-notification-container-name                   = "microservice-notifications"
microservice-notification-repository-uri                   = "quickbooks2018/microservice-notifications:latest"
microservice-notification-fargate-container-port           = 8096

# Cloud Watch Logs for Notification Container
cloudwatch-group-notification-service                      = "/etc/quickbooks2018/svc-notification"
notification-container-log-stream-prefix                   = "microservice-notifications"