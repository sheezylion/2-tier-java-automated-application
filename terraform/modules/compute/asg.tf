 # Auto scaling Group Resource

 resource "aws_autoscaling_group" "this" {
  name = "${var.project_name}-${var.environment}-asg"

  desired_capacity = 2
  min_size         = 2
  max_size         = 3

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  instance_refresh {
    strategy = "Rolling"

  preferences {
      min_healthy_percentage = 0
    }
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "app"
    propagate_at_launch = true
  }
}
