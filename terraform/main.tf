module "network" {
  source        = "./modules/network"
  project_name  = "teste"
  providers = {
    docker = docker.local
  }
}

module "database" {
  source          = "./modules/db"
  project_name    = "teste" 
  db_name         = "appdb"
  db_user         = "appuser"
  db_password     = "changeme123"
  init_sql_path   = "${path.module}/../db/script.sql"
  private_network = module.network.private_network_name
#   labels          = local.common_labels

  providers = {
    docker = docker.local
  }
}

module "backend" {
  source          = "./modules/backend"
  project_name    = "teste"
  image_name      = "local/backend:dev"
  context_path    = "${path.module}/../backend"
  db_host         = module.database.db_alias
  db_port         = 5432
  db_user         = "appuser"
  db_password     = "changeme123"
  db_name         = "appdb"
  private_network = module.network.private_network_name
#   labels          = local.common_labels

  providers = {
    docker = docker.local
  }

  depends_on = [module.database]
}

module "frontend" {
  source         = "./modules/frontend"
  project_name   = "teste"
  image_name     = "local/frontend:dev"
  context_path   = "${path.module}/../frontend"
  public_network = module.network.public_network_name
#   labels         = local.common_labels

  providers = {
    docker = docker.local
  }
}


module "reverse_proxy" {
  source          = "./modules/nginx"
  project_name    = "teste"
  nginx_conf_path = "${path.module}/../nginx/nginx.conf"
  public_network  = module.network.public_network_name
  private_network = module.network.private_network_name
  external_port   = 8080

  providers = {
    docker = docker.local
  }
}