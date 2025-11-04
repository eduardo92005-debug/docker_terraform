variable "project_name" {
  description = "Prefixo usado para nomear recursos Docker (redes, volumes, containers, etc)."
  type        = string
  default     = "desafio-local"

  validation {
    condition     = length(var.project_name) > 0 && can(regex("^[a-zA-Z0-9-_]+$", var.project_name))
    error_message = "O nome do projeto deve conter apenas letras, números, hífens ou underscores e não pode ser vazio."
  }
}

variable "env_file_backend" {
  description = "Caminho para o arquivo .env usado pelo serviço de backend (define variáveis como DB_HOST, PORT, etc)."
  type        = string

  validation {
    condition     = length(var.env_file_backend) > 0 && can(regex(".*\\.env.*", var.env_file_backend))
    error_message = "O caminho do arquivo do backend deve conter '.env' no nome."
  }
}

variable "env_file_database" {
  description = "Caminho para o arquivo .env usado pelo serviço de banco de dados (define variáveis como POSTGRES_DB, POSTGRES_USER, etc)."
  type        = string

  validation {
    condition     = length(var.env_file_database) > 0 && can(regex(".*\\.env.*", var.env_file_database))
    error_message = "O caminho do arquivo do banco deve conter '.env' no nome."
  }
}

variable "env_file_frontend" {
  description = "Caminho para o arquivo .env usado pelo serviço de frontend (define variáveis como PUBLIC_API_BASE, ambiente, etc)."
  type        = string

  validation {
    condition     = length(var.env_file_frontend) > 0 && can(regex(".*\\.env.*", var.env_file_frontend))
    error_message = "O caminho do arquivo do frontend deve conter '.env' no nome."
  }
}

variable "init_sql_file" {
  description = "Caminho absoluto ou relativo para o arquivo SQL utilizado na inicialização do banco de dados (ex: ../db/script.sql)."
  type        = string

  validation {
    condition     = length(var.init_sql_file) > 0 && can(regex("\\.sql$", var.init_sql_file))
    error_message = "O arquivo SQL de inicialização deve ser um caminho válido e terminar com .sql."
  }
}

variable "backend_image" {
  description = "Nome e tag da imagem Docker que será usada para o backend (ex: local/backend:dev)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9\\-/]+:[a-z0-9_.-]+$", var.backend_image))
    error_message = "A imagem do backend deve estar no formato nome:tag (ex: local/backend:dev)."
  }
}

variable "nginx_image" {
  description = "Nome e tag da imagem Docker que será usada para o nginx (ex: local/nginx:dev)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9\\-/]+:[a-z0-9_.-]+$", var.nginx_image))
    error_message = "A imagem do nginx deve estar no formato nome:tag (ex: local/nginx:dev)."
  }
}

variable "frontend_image" {
  description = "Nome e tag da imagem Docker que será usada para o frontend (ex: local/frontend:dev)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9\\-/]+:[a-z0-9_.-]+$", var.frontend_image))
    error_message = "A imagem do frontend deve estar no formato nome:tag (ex: local/frontend:dev)."
  }
}

variable "nginx_conf_file" {
  description = "Caminho absoluto ou relativo para o arquivo de configuração do Nginx usado pelo módulo proxy reverso (ex: ../proxy/nginx.conf)."
  type        = string

  validation {
    condition     = length(var.nginx_conf_file) > 0 && can(regex("\\.conf$", var.nginx_conf_file))
    error_message = "O caminho do arquivo nginx.conf deve ser válido e terminar com .conf."
  }
}

variable "proxy_port" {
  description = "Porta externa exposta pelo container do proxy reverso (ex: 8080)."
  type        = number
  default     = 8080

  validation {
    condition     = var.proxy_port > 0 && var.proxy_port <= 65535
    error_message = "A porta do proxy deve estar entre 1 e 65535."
  }
}
