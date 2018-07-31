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

  enable_nat_gateway = true

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

module "rds-db" {
  source = "./modules/rds"

  subnets = "${module.vpc.database_subnets}"
  security_groups = "${module.security_groups.db_sg_ids}"
}

module "s3-bucket" {
  source = "./modules/s3-bucket"
}
