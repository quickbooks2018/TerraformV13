# RDS

variable "rds-username" {}

variable "rds-password" {}


# Container Definitions for User-Management Container
variable "microservice-user-management-container-name" {}

variable "microservice-user-management-repository-uri" {}

variable "microservice-user-management-fargate-container-port" {}

# Cloud Watch Logs
variable "cloudwatch-group" {}

variable "aws-region" {}

variable "user-management-container-log-stream-prefix" {}

# Task Definition User-Management Service
variable "task-definition-name-user-management-service" {}

variable "task-definition-cpu" {}

variable "task-definition-memory" {}

# Task Definition Notification Service

variable "task-definition-name-notification-service" {}