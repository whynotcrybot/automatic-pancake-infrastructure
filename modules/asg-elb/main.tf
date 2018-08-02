# Get latest Amazon AMI
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

# Define init script which is used to download cookbooks and
# kick-off chef-solo when machine boots up
data "template_file" "init" {
  template = "${file("./config/init.tpl")}"
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "automatic-pancake-machine"

  # Launch configuration
  lc_name = "automatic-pancake-lc"
  recreate_asg_when_lc_changes = true

  key_name        = "aws-master-key-pair"
  image_id        = "${data.aws_ami.amazon_linux.id}"
  instance_type   = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.web_instance_profile.id}"
  security_groups = ["${var.security_groups}"]
  load_balancers  = ["${module.elb.this_elb_id}"]

  user_data = "${data.template_file.init.rendered}"

  root_block_device = [
    {
      volume_size = "10"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name                  = "automatic-pancake-asg"
  vpc_zone_identifier       = ["${var.subnets}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 4
  desired_capacity          = 4
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
      target              = "TCP:80"
      interval            = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 2
    },
  ]
}
