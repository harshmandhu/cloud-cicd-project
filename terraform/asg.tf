# terraform/asg.tf

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app-"
  image_id      = var.app_ami
  instance_type = "t3.micro"
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y && yum install -y docker
    systemctl start docker && systemctl enable docker
    usermod -aG docker ec2-user
    aws ecr get-login-password --region ${var.aws_region} | \
      docker login --username AWS \
      --password-stdin ${aws_ecr_repository.app.repository_url}
  EOF
  )
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  min_size            = 1
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_actions       = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }
}