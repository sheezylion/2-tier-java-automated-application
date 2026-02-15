


# Launch Template

resource "aws_launch_template" "this" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id = data.aws_ami.al2.id

  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

# user_data = base64encode(<<-EOF
#!/bin/bash
#yum update -y
#yum install -y python3
#nohup python3 -m http.server 8080 &
#EOF
# )


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}-app"
      Environment = var.environment
      Role        = "app"
    }
  }
}
