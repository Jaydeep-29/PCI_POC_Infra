resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-sg-alb"
  description = "ALB - only allowed IPs"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-sg-alb" })
}

resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-sg-app"
  description = "App tier"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-sg-app" })
}

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-sg-db"
  description = "DB tier"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, { Name = "${var.name_prefix}-sg-db" })
}

# ALB inbound finite allow-list
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  for_each          = toset(var.allowed_inbound_ips)
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}

# ALB → APP
resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id            = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = var.app_port
  to_port                      = var.app_port
  referenced_security_group_id = aws_security_group.alb.id
}

# APP outbound HTTPS
resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# APP → DB
resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.db.id
}

# DB inbound only from APP
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.app.id
}
