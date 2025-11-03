variable "project_name" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" { sensitive = true }
variable "init_sql_path" {}
variable "private_network" {}
variable "env_file" {}
