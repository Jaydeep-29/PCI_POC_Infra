variable "private_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "db_sg_id" {
  type = string
}

variable "app_instance_type" {
  type = string
}

variable "db_instance_type" {
  type = string
}

variable "app_port" {
  type = number
}

variable "user_data_app" {
  type = string
}

variable "user_data_db" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "app_target_group_arn" {
  type = string
}

