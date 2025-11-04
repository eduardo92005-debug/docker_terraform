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
│   ├── example.tfvars     # Exemplo de preenchimento das variáveis
│   └── terraform.tfvars   # Arquivo real com os valores usados no apply
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
│   └── .env               # Variáveis de ambiente específicas do backend
├── frontend/
│   ├── index.html
│   ├── Dockerfile
│   ├── nginx.conf
│   └── .env               # Variáveis de ambiente específicas do frontend
├── db/
│   ├── script.sql
│   └── .env               # Variáveis de ambiente específicas do banco de dados
└── Makefile
```

---

## 🌍 Variáveis de ambiente

Cada aplicação possui seu próprio arquivo `.env`:

| Pasta | Descrição | Exemplo |
|-------|------------|----------|
| `backend/.env` | Configurações de banco e porta da API | `DB_HOST=postgres`, `DB_USER=appuser`, `DB_PASSWORD=123` |
| `frontend/.env` | Configurações da aplicação web (se houver) | `PUBLIC_API_BASE=/api` |
| `db/.env` | Configurações de inicialização do PostgreSQL | `POSTGRES_USER=appuser`, `POSTGRES_PASSWORD=123` |

Além disso, o Terraform utiliza o arquivo `terraform.tfvars` para receber valores das variáveis globais.

---

## ⚙️ Arquivos de variáveis do Terraform

Dentro da pasta `terraform`, é necessário criar um arquivo chamado:

```
terraform.tfvars
```

Este arquivo contém as respostas das variáveis definidas em `variables.tf`.  
Você pode se basear no modelo fornecido em `example.tfvars`.

**Exemplo (`terraform/example.tfvars`):**

```hcl
project_name   = "desafio-local"
environment    = "local"
public_network = "desafio-local-net-public"
private_network = "desafio-local-net-private"
proxy_port     = 8080
db_name        = "appdb"
db_user        = "appuser"
db_password    = "changeme123"
db_port        = 5432
```

Crie o arquivo `terraform.tfvars` na mesma pasta e ajuste conforme necessário.

---

## 🚀 Como executar

### 1️⃣ Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [GNU Make](https://www.gnu.org/software/make/)

---

### 2️⃣ Inicializar o ambiente

Todos os comandos são executados via **Makefile**.

```bash
make init       # Inicializa módulos e providers Terraform
make validate   # Valida sintaxe e formato
make up         # Sobe toda a infraestrutura local
```

> ⚠️ O comando `make up` executa verificações automáticas (pre-flight check) e faz **rollback (terraform destroy)** caso o `apply` falhe.

---

### 3️⃣ Verificar containers

```bash
make ps
```

Exemplo de saída:
```
🐋 Containers em execução:
desafio-local-proxy      Up 30s   0.0.0.0:8080->8080/tcp
desafio-local-backend    Up 29s   (healthy)
desafio-local-db         Up 28s
desafio-local-dozzle     Up 28s   0.0.0.0:8086->8080/tcp
desafio-local-cadvisor   Up 28s   0.0.0.0:8085->8080/tcp
```

---

### 4️⃣ Testar a aplicação

- **Frontend:**  
  Acesse [http://localhost:8080](http://localhost:8080)
- **Backend (via proxy):**  
  [http://localhost:8080/api](http://localhost:8080/api)
- **Logs:**  
  [http://localhost:8086](http://localhost:8086)
- **Métricas:**  
  [http://localhost:8085](http://localhost:8085)

---

### 5️⃣ Destruir o ambiente

```bash
make down
```

---

## 🛡️ Segurança implementada

| Camada | Medidas aplicadas |
|--------|--------------------|
| **Rede** | Separação entre redes **pública** (proxy/frontend) e **privada** (backend/db) |
| **Proxy (Nginx)** | Fallback SPA, bloqueio de arquivos sensíveis, headers de segurança, controle de métodos e user-agents suspeitos |
| **Backend (Node.js)** | Conexão segura via variáveis de ambiente, tratamento de erros, isolamento na rede privada |
| **Banco (PostgreSQL)** | Volume persistente e acesso restrito apenas ao backend |
| **Infraestrutura (Terraform)** | Estados e secrets ignorados no Git (`.gitignore`), rollback automático em falhas |
| **Automação (Makefile)** | Pré-check de ambiente, rollback automático, scans de segurança, logs separados |
| **Observabilidade** | Logs via Dozzle e métricas leves via cAdvisor |

---

## 🧠 Comandos úteis

| Ação | Comando |
|------|----------|
| Inicializar Terraform | `make init` |
| Validar configuração | `make validate` |
| Subir ambiente | `make up` |
| Destruir ambiente | `make down` |
| Logs do proxy | `make logs-proxy` |
| Logs do backend | `make logs-backend` |
| Logs do frontend | `make logs-frontend` |
| Healthcheck | `make health` |
| Scan de segurança (backend) | `make scan-backend` |
| Scan de segurança (frontend) | `make scan-frontend` |
| Scan de segurança (proxy) | `make scan-proxy` |
| Scan completo | `make scan-all` |

---

## 🧩 Observabilidade

- **Dozzle:** [http://localhost:8086](http://localhost:8086)  
  → Visualize logs de todos os containers em tempo real.  

- **cAdvisor:** [http://localhost:8085](http://localhost:8085)  
  → Veja métricas de CPU, memória e disco de cada container.

---

## 🧼 Limpeza completa

Se quiser resetar completamente o ambiente:
```bash
make clean
```

---

## 🏁 Conclusão

Este projeto demonstra:
- Estrutura modular de Terraform  
- Ambientes Docker reproduzíveis e seguros  
- Proxy reverso com isolamento de rede  
- Automação via Makefile  
- Boas práticas de segurança e observabilidade  

🧠 **Objetivo:** Provar domínio em DevOps prático — com ênfase em segurança, automação e reprodutibilidade local.

---

## 📜 Licença

Este projeto foi desenvolvido apenas para fins de avaliação técnica.  
Todos os componentes utilizados são **open source** e executam **localmente, sem custos de cloud**.

