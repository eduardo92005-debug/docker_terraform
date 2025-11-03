variable "project_name" {}
variable "image_name" {}
variable "context_path" {}
variable "db_host" {}
variable "db_port" {}
variable "db_user" {}
variable "db_password" { sensitive = true }
variable "db_name" {}
variable "private_network" {}
variable "env_file" {}
