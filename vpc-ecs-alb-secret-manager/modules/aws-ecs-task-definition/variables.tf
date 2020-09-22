variable "ecs_task_definition_name" {
  default = ""
}

variable "container-definitions" {
  default = ""
}

variable "task-definition-cpu" {
  default = "1024"
}

variable "task-definition-memory" {
  default = "2048"
}

variable "cloudwatch-group" {}