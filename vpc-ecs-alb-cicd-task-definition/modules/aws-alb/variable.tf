#ALB VARIABLES

variable "alb-name" {
  default = ""
}

variable "internal" {
  default = ""
}

variable "alb-sg" {
  default = ""
}

variable "alb-subnets" {
  type = list(string)
}

variable "enable-deletion-protection" {}

variable "alb-tag" {
  default = ""
}

variable "target-group-arn" {
  default = ""
}

variable "certificate-arn" {
  default = ""
}

variable "rule-path" {
  default = "/"
}