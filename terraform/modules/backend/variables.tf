variable "project_name" {}
variable "image_name" {}
variable "context_path" {}
variable "private_network" {}
variable "env_vars" {
  description = "Lista de variáveis de ambiente no formato KEY=VALUE"
  type        = list(string)
}
variable "run_healthcheck" {}
