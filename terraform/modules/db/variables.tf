variable "project_name" {}
variable "init_sql_path" {}
variable "private_network" {}
variable "env_vars" {
  description = "Lista de variáveis de ambiente no formato KEY=VALUE"
  type        = list(string)
}
