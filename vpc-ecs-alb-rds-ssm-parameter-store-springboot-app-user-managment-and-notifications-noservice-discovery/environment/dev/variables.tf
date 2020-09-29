# RDS

variable "rds-username" {}

variable "rds-password" {}


# Container Definitions for User-Management Container
variable "microservice-user-management-container-name" {}

variable "microservice-user-management-repository-uri" {}

variable "microservice-user-management-fargate-container-port" {}

# Cloud Watch Logs for User-Management Container

variable "aws-region" {}

variable "cloudwatch-group-notification-service" {}

variable "user-management-container-log-stream-prefix" {}

# Task Definition User-Management Service
variable "task-definition-name-user-management-service" {}

variable "task-definition-cpu" {}

variable "task-definition-memory" {}

# Task Definition Notification Service

variable "task-definition-name-notification-service" {}

variable "microservice-notification-container-name" {}

variable "microservice-notification-repository-uri" {}

variable "microservice-notification-fargate-container-port" {}

# Cloud Watch Logs for Notification Container

variable "cloudwatch-group-svc-user-management" {}

variable "notification-container-log-stream-prefix" {}