variable "aws-ecs-service-name" {
  default = "aws-ecs-service-name"
}

variable "ecs-cluster-id" {}

variable "deployment-minimum-healthy-percent" {}

variable "deployment-maximum-percent" {}

variable "security-groups" {}

variable "private-subnets" {}

variable "assign-public-ip" {}

variable "task-definition" {}

variable "desired-count" {}

variable "health-check-grace-period-seconds" {}

variable "target-group-arn" {}

variable "container-name" {}

variable "container-port" {}