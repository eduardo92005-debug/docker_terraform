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