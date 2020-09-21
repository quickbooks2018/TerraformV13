variable "aws-ecscluster-name" {
  default = "aws-ecscluster-name"
}

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

# Auto Scaling
variable "desired-count" {}

variable "min-capacity" {}

variable "max-capacity" {}

# Scale Up Policy
# CPU
variable "cpu-exceeds-percentage" {}
# Memory
variable "memory-exceeds-percentage" {}

# Application Health Check
variable "health-check-grace-period-seconds" {}

variable "target-group-arn" {}

variable "container-name" {}

variable "container-port" {}