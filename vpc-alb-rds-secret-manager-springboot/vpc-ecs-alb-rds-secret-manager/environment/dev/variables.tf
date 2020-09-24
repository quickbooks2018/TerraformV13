# RDS

variable "rds-username" {}

variable "rds-password" {}


# Container Definiton
variable "container-name" {}

variable "repository-uri" {}

variable "fargate-container-port" {}

# Cloud Watch Logs
variable "cloudwatch-group" {}

variable "aws-region" {}

variable "log-stream-prefix" {}

# Task Definition
variable "task-definition-name" {}

variable "task-definition-cpu" {}

variable "task-definition-memory" {}

