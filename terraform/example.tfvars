
project_name = "desafio-local"

env_file_backend  = "../backend/.env.production"
env_file_database = "../db/.env.production"
env_file_frontend = "../frontend/.env.production"

init_sql_file = "../db/script.sql"

backend_image  = "local/backend:dev"
frontend_image = "local/frontend:dev"
nginx_image = "local/nginx:dev"

# Proxy reverso
nginx_conf_file = "../frontend/nginx.conf"
proxy_port      = 8080
