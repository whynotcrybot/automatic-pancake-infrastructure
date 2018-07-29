provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "automatic-pancake-vpc"

  cidr = "10.0.0.0/16"

  azs              = ["us-east-1a", "us-east-1b"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24"]
	public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false

  public_subnet_tags = {
    Name = "public-pancake-vpc"
  }

  vpc_tags = {
    Name = "automatic-pancake-vpc"
  }
}

module "security_groups" {
  source = "./modules/security-groups"

  vpc_id = "${module.vpc.vpc_id}"
}

module "asg-elb" {
  source = "./modules/asg-elb"

  subnets = "${module.vpc.public_subnets}"
  security_groups = "${module.security_groups.asg_sg_ids}"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "automatic-pancake-db"

  engine            = "mysql"
  engine_version    = "5.6"
  instance_class    = "db.t2.micro"
  allocated_storage = 5
  storage_encrypted = false

  name = "pancake"

  username = "pancakeuser"

  password = "password1!"
  port     = "3306"

  vpc_security_group_ids = "${module.security_groups.db_sg_ids}"

	maintenance_window = "Mon:00:00-Mon:03:00"
	backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  # DB subnet group
  subnet_ids = ["${module.vpc.database_subnets}"]

  # DB parameter group
  family = "mysql5.6"

  # DB option group
  major_engine_version = "5.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "automatic-pancake-db"
}
