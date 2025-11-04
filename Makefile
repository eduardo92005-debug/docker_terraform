PROJECT_NAME ?= desafio-local
TF_DIR := terraform

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
	@echo "🔍 Validando configuração..."
	cd $(TF_DIR) && terraform fmt -recursive && terraform validate

# Sobe toda a infraestrutura local com rollback em caso de erro
up: init check validate
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

# Exibe os logs do frontend (Nginx estático)
logs-frontend:
	@echo "Logs do frontend:"
	docker logs -f $(PROJECT_NAME)-frontend

# Exibe todos os logs
logs-all:
	@echo "Logs de todos os containers:"
	docker logs -f $(PROJECT_NAME)-proxy & docker logs -f $(PROJECT_NAME)-backend & docker logs -f $(PROJECT_NAME)-frontend

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

# Escaneia imagem do backend
scan-backend:
	@echo "Rodando análise de segurança no backend..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image local/backend:dev || true

# Escaneia imagem do frontend
scan-frontend:
	@echo "Rodando análise de segurança no frontend..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image local/frontend:dev || true

# Escaneia imagem do proxy
scan-proxy:
	@echo "Rodando análise de segurança no proxy..."
	docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image local/nginx:dev || true

# Escaneia todas as imagens
scan-all: scan-backend scan-frontend scan-proxy
	@echo "Todos os scans finalizados!"

help:
	@echo ""
	@echo "Comandos disponíveis:"
	@echo ""
	@echo "  make init            → Inicializa Terraform e módulos"
	@echo "  make validate        → Formata e valida a configuração"
	@echo "  make up              → Cria containers e redes locais (com rollback automático)"
	@echo "  make down            → Destroi containers e redes"
	@echo "  make logs-proxy      → Mostra logs do Nginx (proxy)"
	@echo "  make logs-backend    → Mostra logs do backend"
	@echo "  make logs-frontend   → Mostra logs do frontend"
	@echo "  make logs-all        → Mostra logs de todos os containers"
	@echo "  make ps              → Lista containers do projeto"
	@echo "  make health          → Checa status dos containers"
	@echo "  make clean           → Remove estados e cache"
	@echo "  make scan-backend    → Executa scan de segurança no backend"
	@echo "  make scan-frontend   → Executa scan de segurança no frontend"
	@echo "  make scan-proxy      → Executa scan de segurança no proxy"
	@echo "  make scan-all        → Executa todos os scans de segurança"
	@echo ""

.PHONY: init validate up down logs-proxy logs-backend logs-frontend logs-all ps clean health scan-backend scan-frontend scan-proxy scan-all help
