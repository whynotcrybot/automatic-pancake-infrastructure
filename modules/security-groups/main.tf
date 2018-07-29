resource "aws_security_group" "allow_all_outbound" {
	name        = "allow_all_outbound"
	description = "Allow all outbound traffic"
	vpc_id      = "${var.vpc_id}"
	
	egress {
		from_port       = 0
		to_port         = 0
		protocol        = "-1"
		cidr_blocks     = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh traffic"
  vpc_id      = "${var.vpc_id}"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
	name        = "allow_http"
	description = "Allow http traffic"
	vpc_id      = "${var.vpc_id}"
	
	ingress {
		from_port       = 80
		to_port         = 80
		protocol        = "tcp"
		cidr_blocks     = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "allow_mysql" {
	name        = "allow_mysql"
	description = "Allow mysql traffic"
	vpc_id      = "${var.vpc_id}"
	
	ingress {
		from_port       = 3306
		to_port         = 3306
		protocol        = "tcp"
		self						= true
	}
}
