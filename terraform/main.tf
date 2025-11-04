module "network" {
  source       = "./modules/network"
  project_name = var.project_name

  providers = {
    docker = docker.local
  }
}

module "database" {
  source          = "./modules/db"
  project_name    = var.project_name
  init_sql_path   = var.init_sql_file
  private_network = module.network.private_network_name
  env_vars        = local.env_database

  providers = {
    docker = docker.local
  }
}

module "backend" {
  source          = "./modules/backend"
  project_name    = var.project_name
  image_name      = var.backend_image
  context_path    = "${path.module}/../backend"
  private_network = module.network.private_network_name
  env_vars        = local.env_backend
  run_healthcheck = false

  providers = {
    docker = docker.local
  }

  depends_on = [module.database]
}

# Não precisa desse modulo a priori, visto que é só um index.html
# Apenas o reverse proxy dá conta.

# module "frontend" {
#   source         = "./modules/frontend"
#   project_name   = var.project_name
#   image_name     = var.frontend_image
#   context_path   = "${path.module}/../frontend"
#   public_network = module.network.public_network_name
#   env_vars       = local.env_frontend
#   run_proxy_healthcheck = false

#   providers = {
#     docker = docker.local
#   }
# }

module "reverse_proxy" {
  source          = "./modules/nginx"
  project_name    = var.project_name
  nginx_conf_path = var.nginx_conf_file
  public_network  = module.network.public_network_name
  private_network = module.network.private_network_name
  external_port   = var.proxy_port
  image_name     = var.nginx_image
  context_path   = "${path.module}/../frontend"
  run_healthcheck = false
  providers = {
    docker = docker.local
  }

  depends_on = [module.backend]
}

module "observability" {
  source          = "./modules/observability"
  project_name    = var.project_name
  private_network = module.network.private_network_name
  public_network  = module.network.public_network_name
  depends_on = [module.backend, module.reverse_proxy]

  providers = {
    docker = docker.local
  }

}
