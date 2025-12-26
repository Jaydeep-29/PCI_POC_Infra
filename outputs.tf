# output "alb_dns_name" {
#   value       = aws_lb.this.dns_name
#   description = "Public ALB DNS name"
# }

output "app_asg_name" {
  value       = module.compute.asg_name
  description = "Application Auto Scaling Group name"
}

output "app_launch_template" {
  value       = module.compute.launch_template_id
  description = "Launch template ID used by ASG"
}

output "db_instance_id" {
  value       = module.compute.db_instance_id
  description = "Database EC2 instance ID"
}

