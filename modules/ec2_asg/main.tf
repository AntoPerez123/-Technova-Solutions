data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    db_host     = var.db_host
    db_user     = var.db_user
    db_password = var.db_password
    db_name     = var.db_name
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = "LabInstanceProfile"
  }

  network_interfaces {
    security_groups             = [var.sg_ec2_id]
    associate_public_ip_address = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(data.template_file.user_data.rendered)
}

resource "aws_autoscaling_group" "this" {
  name = "${var.project_name}-asg"

  desired_capacity = 2
  min_size         = 2
  max_size         = 3

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns

  health_check_type         = "ELB"
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "${var.project_name}-ec2"
    propagate_at_launch = true
  }
}