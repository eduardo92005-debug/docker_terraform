# 🧱 Desafio Técnico – DevOps

Este projeto implementa uma **infraestrutura local segura e automatizada** utilizando **Terraform**, **Docker** e **Makefile**.  
O ambiente foi estruturado para demonstrar habilidades em **infraestrutura como código**, **proxy reverso**, **redes isoladas**, **variáveis de ambiente**, e **automação completa de deploy**.

---

## ⚙️ Arquitetura

```text
+---------------------------+
|         Usuário           |
|     http://localhost:8080 |
+------------+--------------+
             |
             v
   +--------------------+
   |  Proxy Reverso     |  <-- nginx (rede pública + privada)
   |  Porta 8080        |
   +--------------------+
        |         |
        |         +----------------+
        v                          v
+--------------------+    +--------------------+
| Frontend (HTML)    |    | Backend (Node.js)  |
| Rede pública       |    | Rede privada       |
| /usr/share/html    |    | Porta interna 8080 |
+--------------------+    +--------------------+
                                |
                                v
                        +--------------------+
                        | Banco PostgreSQL   |
                        | Rede privada       |
                        +--------------------+
```

Além disso, o ambiente inclui ferramentas leves de **observabilidade**:
- 📜 **Dozzle**: visualização em tempo real dos logs (`http://localhost:8086`)
- 📊 **cAdvisor**: métricas básicas dos containers (`http://localhost:8085`)

---

## 🧩 Estrutura do projeto

```text
project-root/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── example.tfvars
│   ├── terraform.tfvars
│   └── modules/
│       ├── network/
│       ├── backend/
│       ├── frontend/
│       ├── db/
│       ├── nginx/
│       └── observability/
├── backend/
│   ├── index.js
│   ├── package.json
│   ├── Dockerfile
│   └── .env.production
├── frontend/
│   ├── index.html
│   ├── Dockerfile
│   ├── .env.production
│   └── nginx.conf
├── db/
│   ├── script.sql
│   └── .env.production
└── Makefile
```

---

## 🚀 Como subir o projeto (passo a passo completo)

### ⚙️ Criar o arquivo de variáveis do Terraform

Na pasta `terraform/`, copie o arquivo de exemplo e edite os valores:

```bash
cp terraform/example.tfvars terraform/terraform.tfvars
```

**Exemplo ideal de `terraform.tfvars`:**

```hcl
project_name = "desafio-local"

env_file_backend  = "../backend/.env.production"
env_file_database = "../db/.env.production"
env_file_frontend = "../frontend/.env.production"

init_sql_file = "../db/script.sql"

backend_image  = "local/backend:dev"
frontend_image = "local/frontend:dev"
nginx_image    = "local/nginx:dev"

# Proxy reverso
nginx_conf_file = "../frontend/nginx.conf"
proxy_port      = 8080
```

---

### 🧱 Criar os arquivos `.env` de cada serviço

Cada aplicação (backend, frontend e banco) precisa de seu próprio `.env.production`:

**Backend (`backend/.env.production`):**
```bash
PROJECT_NAME=desafio-local
ENVIRONMENT=local
DB_HOST=postgres
DB_PORT=5432
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=changeme123
PORT=8080
HOST=0.0.0.0
```

**Frontend (`frontend/.env.production`):**
```bash
PROJECT_NAME=desafio-local
ENVIRONMENT=local
PROXY_PORT=8080
PUBLIC_API_BASE=/api
```

**Banco (`db/.env.production`):**
```bash
PROJECT_NAME=desafio-local
ENVIRONMENT=local
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=changeme123
DB_HOST=postgres
DB_PORT=5432
DB_NAME=appdb
DB_USER=appuser
DB_PASSWORD=changeme123
PORT=8080
HOST=0.0.0.0
```

---

## 🧰 Funcionalidades do Makefile

O projeto é controlado completamente por comandos `make`:

| Comando | Descrição |
|----------|------------|
| `make init` | Inicializa o Terraform (módulos, providers e validações). |
| `make validate` | Valida a sintaxe e formatação dos arquivos Terraform. |
| `make up` | Executa o `terraform apply` e sobe toda a infraestrutura local. |
| `make ps` | Mostra todos os containers ativos. |
| `make logs-all` | Mostra os logs combinados de todos os containers. |
| `make logs-proxy` | Exibe logs do container Nginx. |
| `make logs-backend` | Exibe logs do container backend. |
| `make logs-frontend` | Exibe logs do container frontend. |
| `make logs-db` | Exibe logs do container do banco de dados. |
| `make scan-backend` | Executa um scan de segurança no backend (npm audit ou trivy). |
| `make scan-frontend` | Executa um scan de segurança no frontend. |
| `make scan-db` | Executa um scan de segurança no db. |
| `make scan-all` | Executa todos os scans de segurança de uma vez. |
| `make health` | Realiza healthcheck dos containers (testa portas e respostas HTTP). |
| `make down` | Destroi toda a infraestrutura (`terraform destroy -auto-approve`). |
| `make clean` | Limpa completamente o ambiente (remove state, volumes e imagens locais). |

---

## 🧠 Subindo o ambiente

Execute:
```bash
make up
```

O comando `make up` executa internamente `terraform apply -auto-approve`, e:
- Cria as redes (`public` e `private`);
- Sobe o banco de dados e aplica o `init.sql`;
- Sobe o backend e conecta ao banco;
- Sobe o frontend e o proxy reverso;
- Configura observabilidade (Dozzle + cAdvisor).

---

## 🔍 Validando o ambiente

Verifique os containers ativos:
```bash
make ps
```

Acesse:
- Frontend → [http://localhost:8080](http://localhost:8080)
- API (via proxy) → [http://localhost:8080/api](http://localhost:8080/api)
- Logs → [http://localhost:8086](http://localhost:8086)
- Métricas → [http://localhost:8085](http://localhost:8085)

---

## 🔻 Destruir o ambiente

```bash
make down
```

---

## 🧼 Limpeza completa

```bash
make clean
```

---

## 📜 Licença

Este projeto foi desenvolvido apenas para fins de avaliação técnica.  
Todos os componentes utilizados são **open source** e executam **localmente, sem custos de cloud**.
