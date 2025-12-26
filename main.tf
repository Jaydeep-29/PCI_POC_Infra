locals {
  common_tags = {
    Project     = "pci-poc"
    Environment = var.environment
    Owner       = "platform-team"
  }

  # User-data templates from root-level user_data folder
  app_user_data = templatefile("${path.root}/user_data/app.sh.tpl", {})
  db_user_data  = templatefile("${path.root}/user_data/db.sh.tpl", {})
}

# -------------------------
# Network module
# -------------------------
module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  name_prefix         = var.name_prefix
  common_tags         = local.common_tags
}

# # -------------------------
# # VPC + Networking
# # -------------------------
# resource "aws_vpc" "this" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#    tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-vpc"
#     }
#   )
# }

# resource "aws_internet_gateway" "this" {
#   vpc_id = aws_vpc.this.id
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-public-igw"
#     }
#   )
# }

# resource "aws_subnet" "public" {
#   for_each = { for i, cidr in var.public_subnet_cidrs : i => cidr }

#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = each.value
#   availability_zone       = data.aws_availability_zones.available.names[tonumber(each.key)]
#   map_public_ip_on_launch = true

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-public-${each.key}"
#     }
#   )
# }

# resource "aws_subnet" "private" {
#   for_each = { for i, cidr in var.private_subnet_cidrs : i => cidr }

#   vpc_id                  = aws_vpc.this.id
#   cidr_block              = each.value
#   availability_zone       = data.aws_availability_zones.available.names[tonumber(each.key)]
#   map_public_ip_on_launch = false

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-private${each.key}"
#     }
#   )
# }

# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.this.id
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-public-rt-public"
#     }
#   )
# }

# resource "aws_route" "public_default" {
#   route_table_id         = aws_route_table.public.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.this.id
# }

# resource "aws_route_table_association" "public" {
#   for_each       = aws_subnet.public
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.public.id
# }

# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-nat-eip"
#     }
#   )
# }

# resource "aws_nat_gateway" "this" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = local.first_public_subnet_id
#   depends_on    = [aws_internet_gateway.this]
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-nat"
#     }
#   )
# }

# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.this.id
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-rt-private"
#     }
#   )
# }

# resource "aws_route" "private_default" {
#   route_table_id         = aws_route_table.private.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.this.id
# }

# resource "aws_route_table_association" "private" {
#   for_each       = aws_subnet.private
#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.private.id
# }

# -------------------------
# Security Groups (PCI 1.3.1 / 1.3.2)
# -------------------------

module "security" {
  source            = "./modules/security"
  vpc_id            = module.network.vpc_id
  allowed_inbound_ips = var.allowed_inbound_ips
  app_port          = var.app_port
  name_prefix       = var.name_prefix
  common_tags       = local.common_tags
}


# resource "aws_security_group" "alb" {
#   name        = "${var.name_prefix}-sg-alb"
#   description = "PCI: Internet-facing ALB, inbound from finite IPs only"
#   vpc_id = module.network.vpc_id

#   tags = merge(
#     local.common_tags,
#     { Name = "${var.name_prefix}-sg-alb" }
#   )
# }

# resource "aws_security_group" "app" {
#   name        = "${var.name_prefix}-sg-app"
#   description = "PCI: App tier, only from ALB, restricted egress"
#   vpc_id = module.network.vpc_id

#   tags = merge(
#     local.common_tags,
#     { Name = "${var.name_prefix}-sg-app" }
#   )
# }

# resource "aws_security_group" "db" {
#   name        = "${var.name_prefix}-sg-db"
#   description = "PCI: DB tier, MySQL only from app, minimal egress"
#   vpc_id = module.network.vpc_id

#   tags = merge(
#     local.common_tags,
#     { Name = "${var.name_prefix}-sg-db" }
#   )
# }



# resource "aws_vpc_security_group_ingress_rule" "alb_http" {
#   for_each          = toset(var.allowed_inbound_ips)
#   security_group_id = aws_security_group.alb.id
#   ip_protocol       = "tcp"
#   from_port         = 80
#   to_port           = 80
#   cidr_ipv4         = each.value
# }

# resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
#   security_group_id            = aws_security_group.alb.id
#   ip_protocol                  = "tcp"
#   from_port                    = var.app_port
#   to_port                      = var.app_port
#   referenced_security_group_id = aws_security_group.app.id
# }

# resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
#   security_group_id            = aws_security_group.app.id
#   ip_protocol                  = "tcp"
#   from_port                    = var.app_port
#   to_port                      = var.app_port
#   referenced_security_group_id = aws_security_group.alb.id
# }

# resource "aws_vpc_security_group_egress_rule" "app_dns_udp" {
#   security_group_id = aws_security_group.app.id
#   ip_protocol       = "udp"
#   from_port         = 53
#   to_port           = 53
#   cidr_ipv4         = var.vpc_cidr
# }

# resource "aws_vpc_security_group_egress_rule" "app_dns_tcp" {
#   security_group_id = aws_security_group.app.id
#   ip_protocol       = "tcp"
#   from_port         = 53
#   to_port           = 53
#   cidr_ipv4         = var.vpc_cidr
# }

# resource "aws_vpc_security_group_egress_rule" "app_https" {
#   for_each          = toset(var.secureweb_cidrs)
#   security_group_id = aws_security_group.app.id
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   cidr_ipv4         = "0.0.0.0/0"
#   # cidr_ipv4         = each.value
# }

# resource "aws_vpc_security_group_egress_rule" "app_to_db" {
#   security_group_id            = aws_security_group.app.id
#   ip_protocol                  = "tcp"
#   from_port                    = 3306
#   to_port                      = 3306
#   referenced_security_group_id = aws_security_group.db.id
# }

# resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
#   security_group_id            = aws_security_group.db.id
#   ip_protocol                  = "tcp"
#   from_port                    = 3306
#   to_port                      = 3306
#   referenced_security_group_id = aws_security_group.app.id
# }
# resource "aws_vpc_security_group_egress_rule" "db_dns_udp" {
#   security_group_id = aws_security_group.db.id
#   ip_protocol       = "udp"
#   from_port         = 53
#   to_port           = 53
#   cidr_ipv4         = var.vpc_cidr
# }
# resource "aws_vpc_security_group_egress_rule" "db_dns_tcp" {
#   security_group_id = aws_security_group.db.id
#   ip_protocol       = "tcp"
#   from_port         = 53
#   to_port           = 53
#   cidr_ipv4         = var.vpc_cidr
# }


# ALB + Target Group + HTTPS Listener


module "alb" {
  source = "./modules/alb"

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids

  alb_sg_id = module.security.alb_sg_id

  app_port = var.app_port

  name_prefix = var.name_prefix
  common_tags = local.common_tags
}

# -------------------------
# Compute
# -------------------------

module "compute" {
  source = "./modules/compute"
  private_subnet_ids = module.network.private_subnet_ids

  app_sg_id = module.security.app_sg_id
  db_sg_id  = module.security.db_sg_id

  app_instance_type = var.app_instance_type
  db_instance_type  = var.db_instance_type

  user_data_app = local.app_user_data
  user_data_db  = local.db_user_data

  app_target_group_arn = module.alb.target_group_arn

  app_port = var.app_port

  name_prefix = var.name_prefix
  common_tags = local.common_tags
}



# -------------------------
# EC2 Instances
# -------------------------
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }
# }


# resource "aws_launch_template" "app" {
#   name_prefix   = "${var.name_prefix}-lt-"
#   image_id      = data.aws_ami.amazon_linux.id
#   instance_type = var.app_instance_type

#   vpc_security_group_ids = [module.security.app_sg_id]

#   user_data = base64encode(local.app_user_data)

#   tag_specifications {
#     resource_type = "instance"
#     tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-app"
#     }
#   )
#   }
# }

# resource "aws_autoscaling_group" "app" {
#   name                      = "${var.name_prefix}-asg"
#   desired_capacity          = 2
#   max_size                  = 3
#   min_size                  = 1

#   vpc_zone_identifier = [
#   module.network.private_subnet_ids[0],
#   module.network.private_subnet_ids[1],
# ]

#   health_check_type         = "ELB"
#   target_group_arns         = [aws_lb_target_group.app.arn]

#   launch_template {
#     id      = aws_launch_template.app.id
#     version = "$Latest"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }

#   tag {
#     key                 = "Name"
#     value               = "${var.name_prefix}-app"
#     propagate_at_launch = true
#   }
# }


# resource "aws_instance" "db" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type               = var.db_instance_type
#   subnet_id = module.network.private_subnet_ids[1]
#   vpc_security_group_ids      = [module.security.db_sg_id]
#   associate_public_ip_address = false
#   user_data                   = local.db_user_data
#   key_name                    = var.key_name != "" ? var.key_name : null

#   # lifecycle {
#   #   prevent_destroy = true
#   #   }

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-db"
#     }
#   )
# }

# -------------------------



# resource "aws_lb" "this" {
#   name               = "${var.name_prefix}-alb"
#   load_balancer_type = "application"
#   internal           = false
#   security_groups    = [module.security.alb_sg_id]
#   subnets = module.network.public_subnet_ids
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-alb"
#     }
#   )
# }

# resource "aws_lb_target_group" "app" {
#   name        = "${var.name_prefix}-tg"
#   port        = var.app_port
#   protocol    = "HTTP"
#   vpc_id = module.network.vpc_id
#   target_type = "instance"

#   health_check {
#     enabled             = true
#     path                = "/"
#     healthy_threshold   = 2
#     unhealthy_threshold = 3
#     interval            = 15
#     timeout             = 5
#     matcher             = "200-399"
#   }

#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${var.name_prefix}-tg"
#     }
#   )
# }


# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.acm_certificate_arn
#   ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }
#
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 80
#   protocol          = "HTTP"
#
#   default_action {
#     type = "redirect"
#
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#       }
#   }
# }

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.app.arn
#   }
# }


