variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "name_prefix" {
  type        = string
  description = "Name prefix for network resources"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all network resources"
}
