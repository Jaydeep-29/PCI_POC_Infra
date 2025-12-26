variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "app_port" {
  type = number
}

variable "target_app_instance_type" {
  description = "Target type for the ALB TG (instance or ip)"
  type        = string
  default     = "instance"
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

