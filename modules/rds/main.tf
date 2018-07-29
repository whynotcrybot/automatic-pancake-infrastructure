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
  
  vpc_security_group_ids = "${var.security_groups}"
  
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  # disable backups to create DB faster
  backup_retention_period = 0
  
  # DB subnet group
  subnet_ids = "${var.subnets}"
  
  # DB parameter group
  family = "mysql5.6"
  
  # DB option group
  major_engine_version = "5.6"
  
  # Snapshot name upon DB deletion
  final_snapshot_identifier = "automatic-pancake-db"
}

data "template_file" "restoreSchema" {
  template = "${file("./config/restoreSchema.tpl")}"

  vars {
    DATABASE_ENDPOINT = "${module.db.this_db_instance_address}"
    DATABASE_PORT     = "${module.db.this_db_instance_port}"
    DATABASE_NAME     = "${module.db.this_db_instance_name}"
    DATABASE_USER     = "${module.db.this_db_instance_username}"
    DATABASE_PASSWORD = "${module.db.this_db_instance_password}"
  }
}

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

resource "aws_instance" "apply-db-schema" {
  depends_on = ["module.db"]

  ami           = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  user_data = "${data.template_file.restoreSchema.rendered}"

  key_name        = "aws-master-key-pair"
  vpc_security_group_ids = ["${var.security_groups}"]
  subnet_id = "${var.subnets[0]}"

  instance_initiated_shutdown_behavior = "terminate"
}
