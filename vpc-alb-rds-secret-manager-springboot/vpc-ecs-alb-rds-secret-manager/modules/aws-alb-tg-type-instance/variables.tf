variable "alb-tg-name" {
  default = ""
}
variable "target-group-port" {
  default = ""
}

variable "target-group-protocol" {
  default = ""
}

variable "vpc-id" {
  default = ""
}

# Health Check

variable "health-check" {
  default = true
}

variable "interval" {
  default = "30"
}

variable "path" {
  default = "/"
}

variable "port" {
  default = "80"
}

variable "protocol" {
  default = "HTTP"
}

variable "timeout" {
  default = "3"
}

variable "unhealthy-threshold" {
  default = "3"
}

variable "matcher" {
  default = "200,202"
}

