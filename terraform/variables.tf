variable "project_name" {
  description = "Prefixo usado para nomear recursos Docker (redes, volumes, containers, etc)."
  type        = string
  default     = "desafio-local"
}

variable "env_file_backend" {
  description = "Caminho para o arquivo .env usado pelo serviço de backend (define variáveis como DB_HOST, PORT, etc)."
  type        = string
}

variable "env_file_database" {
  description = "Caminho para o arquivo .env usado pelo serviço de banco de dados (define variáveis como POSTGRES_DB, POSTGRES_USER, etc)."
  type        = string
}

variable "env_file_frontend" {
  description = "Caminho para o arquivo .env usado pelo serviço de frontend (define variáveis como PUBLIC_API_BASE, ambiente, etc)."
  type        = string
}

variable "init_sql_file" {
  description = "Caminho absoluto ou relativo para o arquivo SQL utilizado na inicialização do banco de dados (ex: ../db/script.sql)."
  type        = string
}

variable "backend_image" {
  description = "Nome e tag da imagem Docker que será usada para o backend (ex: local/backend:dev)."
  type        = string
}

variable "nginx_image" {
  description = "Nome e tag da imagem Docker que será usada para o nginx (ex: local/nginx:dev)."
  type        = string
}

variable "frontend_image" {
  description = "Nome e tag da imagem Docker que será usada para o frontend (ex: local/frontend:dev)."
  type        = string
}

variable "nginx_conf_file" {
  description = "Caminho absoluto ou relativo para o arquivo de configuração do Nginx usado pelo módulo proxy reverso (ex: ../proxy/nginx.conf)."
  type        = string
}

variable "proxy_port" {
  description = "Porta externa exposta pelo container do proxy reverso (ex: 8080)."
  type        = number
  default     = 8080
}
