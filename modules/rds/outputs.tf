output "db_endpoint" {
  value = "${module.db.this_db_instance_address}"
}
output "db_user" {
  value = "${module.db.this_db_instance_username}"
}
output "db_password" {
  value = "${module.db.this_db_instance_password}"
}
output "db_name" {
  value = "${module.db.this_db_instance_name}"
}
