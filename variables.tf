variable "aws_region" {
  type        = string
  description = "AWS region for deployment"
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for resource names"
  default     = "pci-poc"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Two public subnet CIDRs in different AZs (ALB requirement)"
  default     = ["10.50.0.0/24", "10.50.1.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (app + db)"
  default     = ["10.50.10.0/24", "10.50.11.0/24"]
}

variable "allowed_inbound_ips" {
  type        = list(string)
  description = "Finite list of client IPs/CIDRs allowed to reach ALB"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the ALB HTTPS listener"
}

variable "app_instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  type        = string
  default     = "t3.micro"
}

variable "app_port" {
  type        = number
  description = "App listener port on the EC2 instance"
  default     = 80
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name for SSH (leave empty to skip)"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, stage, prod)"
  default     = "dev"
}


variable "secureweb_cidrs" {
  type        = list(string)
  description = "CIDR(s) for secureweb.com (POC – normally use proxy/DNS-based controls)"
  default     = []  # fill with real CIDR(s) when known
}
