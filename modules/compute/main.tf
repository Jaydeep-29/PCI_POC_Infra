data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.app_instance_type

  vpc_security_group_ids = [var.app_sg_id]
  user_data              = base64encode(var.user_data_app)

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.common_tags,
      { Name = "${var.name_prefix}-app" }
    )
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.name_prefix}-asg"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 60
  target_group_arns = [var.app_target_group_arn]
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-app"
    propagate_at_launch = true
  }
}

resource "aws_instance" "db" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.db_instance_type
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = [var.db_sg_id]
  user_data              = var.user_data_db

  tags = merge(
    var.common_tags,
    { Name = "${var.name_prefix}-db" }
  )
}
