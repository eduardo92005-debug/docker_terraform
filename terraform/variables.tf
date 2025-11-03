variable "project_name" {
  description = "Prefixo para nomear recursos (usado em redes, volumes, containers)"
  type        = string
  default     = "desafio-local"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_user" {
  description = "Usuário do banco"
  type        = string
}

variable "db_password" {
  description = "Senha do banco"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Porta do banco PostgreSQL"
  type        = number
}

variable "init_sql_file" {
  description = "Nome do arquivo SQL de inicialização"
  type        = string
}

variable "backend_image" {
  description = "Nome da imagem Docker para o backend"
  type        = string
}

variable "frontend_image" {
  description = "Nome da imagem Docker para o frontend"
  type        = string
}

variable "proxy_port" {
  description = "Porta externa exposta pelo proxy reverso"
  type        = number
}

variable "nginx_conf_file" {
  description = "Arquivo de configuração do Nginx usado pelo módulo reverse_proxy"
  type        = string
}


variable "env_file" {
  description = "Caminho do arquivo .env global"
  type        = string
}
