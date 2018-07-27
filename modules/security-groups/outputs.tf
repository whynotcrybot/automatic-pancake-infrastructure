output "ids" {
	value = [
		"${aws_security_group.allow_all_outbound.id}",
		"${aws_security_group.allow_ssh.id}",
		"${aws_security_group.allow_http.id}",
	]
}
