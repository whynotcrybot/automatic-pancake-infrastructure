output "asg_sg_ids" {
  value = [
    "${aws_security_group.allow_all_outbound.id}",
    "${aws_security_group.allow_ssh.id}",
    "${aws_security_group.allow_http.id}",
    "${aws_security_group.allow_mysql.id}",
  ]
}

output "db_sg_ids" {
  value = [
    "${aws_security_group.allow_all_outbound.id}",
    "${aws_security_group.allow_mysql.id}",
  ]
}
