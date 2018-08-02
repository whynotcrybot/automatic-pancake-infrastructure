data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

data "template_file" "init" {
  template = "${file("./config/init.tpl")}"
}

resource "aws_iam_role" "web_iam_role" {
  name = "web_iam_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]	
}
EOF
}

resource "aws_iam_instance_profile" "web_instance_profile" {
  name = "web_instance_profile"
  role = "${aws_iam_role.web_iam_role.name}"
}

resource "aws_iam_role_policy" "access_s3_bucket" {
  name = "access_s3_bucket"
  role = "${aws_iam_role.web_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::automatic-pancake-configuration-bucket"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::automatic-pancake-configuration-bucket/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "access_ssm_parameter_store" {
  name = "access_ssm_parameter_store"
  role = "${aws_iam_role.web_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ssm:DescribeParameters",
              "ssm:GetParameterHistory",
              "ssm:GetParametersByPath",
              "ssm:GetParameters",
              "ssm:GetParameter"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "automatic-pancake-machine"

  # Launch configuration
  lc_name = "automatic-pancake-lc"

  key_name        = "aws-master-key-pair"
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"
  security_groups = ["${var.security_groups}"]
  load_balancers  = ["${module.elb.this_elb_id}"]

  user_data = "${data.template_file.init.rendered}"

  root_block_device = [
    {
      volume_size = "20"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "automatic-pancake-asg"
  vpc_zone_identifier       = ["${var.subnets}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
}

module "elb" {
  source = "terraform-aws-modules/elb/aws"

  name = "automatic-pancake-elb"

  subnets         = ["${var.subnets}"]
  security_groups = ["${var.security_groups}"]
  internal        = false

  listener = [
    {
      instance_port     = "80"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = [
    {
      target              = "HTTP:80/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]
}

#resource "aws_autoscaling_policy" "example-cpu-policy" {
  #name = "example-cpu-policy"
  #autoscaling_group_name = "${aws_autoscaling_group.example-autoscaling.name}"
  #adjustment_type = "ChangeInCapacity"
  #scaling_adjustment = "1"
  #cooldown = "300"
  #policy_type = "SimpleScaling"
#}
#resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
  #alarm_name = "example-cpu-alarm"
  #alarm_description = "example-cpu-alarm"
  #comparison_operator = "GreaterThanOrEqualToThreshold"
  #evaluation_periods = "2"
  #metric_name = "CPUUtilization"
  #namespace = "AWS/EC2"
  #period = "120"
  #statistic = "Average"
  #threshold = "30"
  #dimensions = {
    #"AutoScalingGroupName" = "${aws_autoscaling_group.example-autoscaling.name}"
  #}
  #actions_enabled = true
  #alarm_actions = ["${aws_autoscaling_policy.example-cpu-policy.arn}"]
#}
## scale down alarm
#resource "aws_autoscaling_policy" "example-cpu-policy-scaledown" {
  #name = "example-cpu-policy-scaledown"
  #autoscaling_group_name = "${aws_autoscaling_group.example-autoscaling.name}"
  #adjustment_type = "ChangeInCapacity"
  #scaling_adjustment = "-1"
  #cooldown = "300"
  #policy_type = "SimpleScaling"
#}
#resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm-scaledown" {
  #alarm_name = "example-cpu-alarm-scaledown"
  #alarm_description = "example-cpu-alarm-scaledown"
  #comparison_operator = "LessThanOrEqualToThreshold"
  #evaluation_periods = "2"
  #metric_name = "CPUUtilization"
  #namespace = "AWS/EC2"
  #period = "120"
  #statistic = "Average"
  #threshold = "5"
  #dimensions = {
    #"AutoScalingGroupName" = "${aws_autoscaling_group.example-autoscaling.name}"
  #}
  #actions_enabled = true
  #alarm_actions = ["${aws_autoscaling_policy.example-cpu-policy-scaledown.arn}"]
#}
