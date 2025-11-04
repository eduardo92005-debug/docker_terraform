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

### 🧩 1️⃣ Estrutura esperada antes de iniciar

Certifique-se de que seu diretório do projeto esteja organizado da seguinte forma:

```
project-root/
├── backend/
│   ├── Dockerfile
│   ├── index.js
│   ├── package.json
│   └── .env.production
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── .env.production
│   └── nginx.conf
├── db/
│   ├── script.sql
│   └── .env.production
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── example.tfvars
│   ├── terraform.tfvars
│   └── modules/
│       ├── network/
│       ├── db/
│       ├── backend/
│       ├── frontend/
│       ├── nginx/
│       └── observability/
└── Makefile
```

---

### ⚙️ 2️⃣ Criar o arquivo de variáveis do Terraform

Na pasta `terraform/`, você encontrará o arquivo `example.tfvars`.  
Esse arquivo é **um modelo** contendo todas as variáveis necessárias para o Terraform.

Crie o arquivo real chamado `terraform.tfvars` na mesma pasta com base nele:

```bash
cp terraform/example.tfvars terraform/terraform.tfvars
```

Abra o arquivo `terraform.tfvars` e defina os valores conforme o ambiente local.  
Um exemplo ideal seria:

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

💡 **Importante:**
- Os caminhos (`../backend/.env.production`, etc.) são relativos à pasta `terraform/`.
- O Terraform usará essas variáveis para repassar os arquivos `.env` para cada container.

---

### 🧱 3️⃣ Criar os arquivos `.env` de cada serviço

Cada aplicação (backend, frontend e banco) precisa de seu próprio `.env.production`.

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

### 🧠 4️⃣ Inicializar o Terraform

```bash
make up
```

O comando `make up` executa internamente:

```bash
terraform apply -auto-approve
```

Ele:
- Cria as redes (`public` e `private`);
- Sobe o banco de dados e aplica o `init.sql`;
- Sobe o backend e conecta ao banco;
- Sobe o frontend;
- Sobe o proxy reverso (Nginx);
- Configura observabilidade (Dozzle + cAdvisor);
- Exibe o status dos containers ao final.

---

### 🧾 6️⃣ Validar se tudo está rodando

Verifique os containers ativos:
```bash
make ps
```

Saída esperada:
```
🐋 Containers em execução:
desafio-local-proxy      Up   0.0.0.0:8080->8080/tcp
desafio-local-backend    Up   (healthy)
desafio-local-db         Up
desafio-local-frontend   Up
desafio-local-dozzle     Up   0.0.0.0:8086->8080/tcp
desafio-local-cadvisor   Up   0.0.0.0:8085->8080/tcp
```

Acesse:
- Frontend → [http://localhost:8080](http://localhost:8080)
- API (via proxy) → [http://localhost:8080/api](http://localhost:8080/api)
- Logs → [http://localhost:8086](http://localhost:8086)
- Métricas → [http://localhost:8085](http://localhost:8085)

---

### 🔻 7️⃣ Destruir o ambiente

```bash
make down
```

Isso executa `terraform destroy -auto-approve`  
e remove todas as redes, volumes e containers criados.

---

### 🔄 8️⃣ Resetar completamente (limpeza total)

```bash
make clean
```

Isso remove:
- estado Terraform (`terraform.tfstate`);
- volumes Docker persistentes;
- imagens locais;
- caches temporários.

---

## 📜 Licença

Este projeto foi desenvolvido apenas para fins de avaliação técnica.  
Todos os componentes utilizados são **open source** e executam **localmente, sem custos de cloud**.
