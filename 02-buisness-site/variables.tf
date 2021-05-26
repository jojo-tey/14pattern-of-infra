variable "AWS_ACCESS_KEY" {
  type = string
}

variable "AWS_SECRET_KEY" {
  type = string
}

variable "AWS_REGION" {
  type = string
}

variable "AMIS" {
  type = string
}

variable "enable_autoscaling" {
  description = "if set to true, enable auto scaling"
}
