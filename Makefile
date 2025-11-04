PROJECT_NAME ?= desafio-local
TF_DIR := terraform

# Gera automaticamente os .env.production e o terraform.tfvars (se não existirem)
env-init:
	@echo "Gerando arquivos .env.production padrão..."
	@if [ -f backend/.env.example ] && [ ! -f backend/.env.production ]; then cp backend/.env.example backend/.env.production && echo "✅ backend/.env.production criado"; else echo "ℹ️ backend/.env.production já existe ou backend/.env.example ausente"; fi
	@if [ -f frontend/.env.example ] && [ ! -f frontend/.env.production ]; then cp frontend/.env.example frontend/.env.production && echo "✅ frontend/.env.production criado"; else echo "ℹ️ frontend/.env.production já existe ou frontend/.env.example ausente"; fi
	@if [ -f db/.env.example ] && [ ! -f db/.env.production ]; then cp db/.env.example db/.env.production && echo "✅ db/.env.production criado"; else echo "ℹ️ db/.env.production já existe ou db/.env.example ausente"; fi
	@echo "Gerando terraform/terraform.tfvars (a partir de terraform/example.tfvars)..."
	@if [ -f $(TF_DIR)/example.tfvars ] && [ ! -f $(TF_DIR)/terraform.tfvars ]; then cp $(TF_DIR)/example.tfvars $(TF_DIR)/terraform.tfvars && echo "✅ terraform/terraform.tfvars criado"; else echo "ℹ️ terraform/terraform.tfvars já existe ou $(TF_DIR)/example.tfvars ausente"; fi

check:
	@echo "Verificando pré-requisitos do ambiente..."
	@if ! command -v terraform >/dev/null 2>&1; then \
		echo "Terraform não encontrado. Instale antes de continuar: https://developer.hashicorp.com/terraform/downloads"; \
		exit 1; \
	fi
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "Docker não encontrado. Instale antes de continuar: https://docs.docker.com/get-docker/"; \
		exit 1; \
	fi
	@if ! docker info >/dev/null 2>&1; then \
		echo "Docker não está em execução."; \
		exit 1; \
	fi
	@echo "Pré-requisitos OK! Terraform e Docker estão disponíveis."

# Inicializa Terraform
init:
	@echo "Inicializando Terraform..."
	cd $(TF_DIR) && terraform init -upgrade

# Valida sintaxe e formato
validate:
	@echo "Validando configuração..."
	cd $(TF_DIR) && terraform fmt -recursive && terraform validate

# Sobe toda a infraestrutura local com rollback em caso de erro
up: env-init check init validate
	@echo "Criando ambiente Docker local..."
	cd $(TF_DIR) && terraform apply -auto-approve || ( \
		echo "Erro detectado durante o apply! Iniciando rollback..." && \
		cd $(TF_DIR) && terraform destroy -auto-approve && \
		exit 1 \
	)

# Destrói todos os containers e redes criados
down:
	@echo "Removendo ambiente..."
	cd $(TF_DIR) && terraform destroy -auto-approve

# Exibe os logs do proxy (Nginx)
logs-proxy:
	@echo "Logs do proxy:"
	docker logs -f $(PROJECT_NAME)-proxy

# Exibe os logs do backend (Node.js)
logs-backend:
	@echo "Logs do backend:"
	docker logs -f $(PROJECT_NAME)-backend

# Exibe os logs do banco (PostgreSQL)
logs-db:
	@echo "Logs do database:"
	docker logs -f $(PROJECT_NAME)-db

# Exibe os logs do frontend (caso exista um container dedicado)
# logs-frontend:
# 	@echo "Logs do frontend:"
# 	docker logs -f $(PROJECT_NAME)-frontend

# Exibe todos os logs (proxy + backend; ajuste conforme necessário)
logs-all:
	@echo "Logs de todos os containers:"
	(docker logs -f $(PROJECT_NAME)-proxy &) ; \
	(docker logs -f $(PROJECT_NAME)-backend &)

# Mostra o status dos containers
ps:
	@echo "Containers em execução:"
	docker ps --filter "name=$(PROJECT_NAME)"

# Força limpeza total (estado, cache, etc)
clean:
	@echo "Limpando arquivos temporários..."
	rm -rf $(TF_DIR)/.terraform $(TF_DIR)/terraform.tfstate* $(TF_DIR)/.terraform.lock.hcl

# Verifica se o ambiente está saudável (nginx, backend, db)
health:
	@echo "Testando containers..."
	docker ps --filter "name=$(PROJECT_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Scans de segurança (Trivy)
scan-backend:
	@echo "Rodando análise de segurança no backend..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image local/backend:dev || true

scan-frontend:
	@echo "Rodando análise de segurança no frontend..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image local/frontend:dev || true

scan-db:
	@echo "Rodando análise de segurança no database..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image postgres:15.8 || true

# Escaneia todas as imagens
scan-all: scan-backend scan-frontend scan-db
	@echo "Todos os scans finalizados!"

help:
	@echo ""
	@echo "Comandos disponíveis:"
	@echo ""
	@echo "  make env-init        → Gera .env.production e terraform.tfvars (a partir dos exemplos)"
	@echo "  make init            → Inicializa Terraform e módulos"
	@echo "  make validate        → Formata e valida a configuração"
	@echo "  make up              → Cria containers e redes locais (com rollback automático)"
	@echo "  make down            → Destroi containers e redes"
	@echo "  make logs-proxy      → Mostra logs do Nginx (proxy)"
	@echo "  make logs-backend    → Mostra logs do backend"
	@echo "  make logs-db         → Mostra logs do banco"
	@echo "  make logs-all        → Mostra logs de todos os containers"
	@echo "  make ps              → Lista containers do projeto"
	@echo "  make health          → Checa status dos containers"
	@echo "  make clean           → Remove estados e cache"
	@echo "  make scan-backend    → Executa scan de segurança no backend"
	@echo "  make scan-frontend   → Executa scan de segurança no frontend"
	@echo "  make scan-db         → Executa scan de segurança no banco"
	@echo "  make scan-all        → Executa todos os scans de segurança"
	@echo ""

.PHONY: env-init init validate up down logs-proxy logs-backend logs-frontend logs-db logs-all ps clean health scan-backend scan-frontend scan-db scan-all help
