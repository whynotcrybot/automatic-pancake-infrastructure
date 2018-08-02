resource "aws_ssm_parameter" "db_endpoint" {
  name  = "db_endpoint"
  type  = "String"
  value = "${var.db_endpoint}"
}

resource "aws_ssm_parameter" "db_user" {
  name  = "db_user"
  type  = "String"
  value = "${var.db_user}"
}

resource "aws_ssm_parameter" "db_password" {
  name  = "db_password"
  type  = "String"
  value = "${var.db_password}"
}

resource "aws_ssm_parameter" "db_name" {
  name  = "db_name"
  type  = "String"
  value = "${var.db_name}"
}
