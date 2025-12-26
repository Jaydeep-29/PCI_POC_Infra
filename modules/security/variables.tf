variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups"
}

variable "allowed_inbound_ips" {
  type        = list(string)
  description = "Allowed CIDRs to ALB"
}

variable "app_port" {
  type = number
}

variable "common_tags" {
  type = map(string)
}

variable "name_prefix" {
  type = string
}
