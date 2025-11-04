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

## 🧰 Requisitos necessários

Antes de rodar o projeto, é necessário ter as seguintes ferramentas instaladas no sistema:

| Ferramenta | Versão mínima | Link para instalação |
|-------------|----------------|----------------------|
| **Docker** | 20.10+ | [https://docs.docker.com/get-docker](https://docs.docker.com/get-docker) |
| **Terraform** | 1.5+ | [https://developer.hashicorp.com/terraform/downloads](https://developer.hashicorp.com/terraform/downloads) |
| **GNU Make** | 4.0+ | [https://www.gnu.org/software/make/](https://www.gnu.org/software/make/) |

Para verificar se as ferramentas estão instaladas corretamente, execute:
```bash
docker --version
terraform --version
make --version
```

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

Agora, todo o processo de configuração inicial é automatizado com o comando `make env-init`, que prepara os arquivos `.env.production` e o `terraform.tfvars`.

---

### 🧩 Passo 1️⃣ — Preparar os arquivos de ambiente e variáveis

Execute o comando abaixo para gerar os arquivos necessários automaticamente:

```bash
make env-init
```

Este comando faz:
- Cria `backend/.env.production`, `frontend/.env.production` e `db/.env.production` caso ainda não existam (baseados em `.env.example` se disponível).
- Cria `terraform/terraform.tfvars` com base em `terraform/example.tfvars` caso ainda não exista.

---

### ⚙️ Passo 2️⃣ — Subir a infraestrutura

Depois que os arquivos foram gerados, suba o ambiente com:

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

### 🔍 Passo 3️⃣ — Verificar se tudo está rodando

Veja os containers ativos:

```bash
make ps
```

Acesse:
- Frontend → [http://localhost:8080](http://localhost:8080)
- API (via proxy) → [http://localhost:8080/api](http://localhost:8080/api)
- Logs → [http://localhost:8086](http://localhost:8086)
- Métricas → [http://localhost:8085](http://localhost:8085)

---

### 🧰 Passo 4️⃣ — Logs e observabilidade

Comandos úteis:

```bash
make logs-proxy      # Logs do proxy reverso (Nginx)
make logs-backend    # Logs do backend (Node.js)
make logs-db         # Logs do banco de dados (PostgreSQL)
make logs-all        # Mostra logs combinados de todos os serviços
```

---

### 🔻 Passo 5️⃣ — Destruir o ambiente

```bash
make down
```

Este comando executa `terraform destroy -auto-approve`, removendo containers, volumes e redes.

---

### 🧼 Passo 6️⃣ — Limpeza completa

```bash
make clean
```

Remove arquivos temporários, cache, estados do Terraform e reconfigura o ambiente.

---

## 🧰 Outros comandos disponíveis

| Comando | Descrição |
|----------|------------|
| `make init` | Inicializa o Terraform (módulos e providers). |
| `make validate` | Valida e formata os arquivos Terraform. |
| `make health` | Exibe status de containers e portas. |
| `make scan-backend` | Executa scan de segurança no backend. |
| `make scan-frontend` | Executa scan de segurança no frontend. |
| `make scan-db` | Executa scan de segurança no banco. |
| `make scan-all` | Executa todos os scans de segurança de uma vez. |

---

## 📜 Licença

Este projeto foi desenvolvido apenas para fins de avaliação técnica.  
Todos os componentes utilizados são **open source** e executam **localmente, sem custos de cloud**.
