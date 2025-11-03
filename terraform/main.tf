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
  db_name         = var.db_name
  db_user         = var.db_user
  db_password     = var.db_password
  init_sql_path   = "${path.module}/../db/${var.init_sql_file}"
  private_network = module.network.private_network_name
  # labels        = local.common_labels

  providers = {
    docker = docker.local
  }
}

module "backend" {
  source          = "./modules/backend"
  project_name    = var.project_name
  image_name      = var.backend_image
  context_path    = "${path.module}/../backend"
  db_host         = module.database.db_alias
  db_port         = var.db_port
  db_user         = var.db_user
  db_password     = var.db_password
  db_name         = var.db_name
  private_network = module.network.private_network_name
  # labels        = local.common_labels

  providers = {
    docker = docker.local
  }

  depends_on = [module.database]
}

module "frontend" {
  source         = "./modules/frontend"
  project_name   = var.project_name
  image_name     = var.frontend_image
  context_path   = "${path.module}/../frontend"
  public_network = module.network.public_network_name
  # labels       = local.common_labels

  providers = {
    docker = docker.local
  }
}

module "reverse_proxy" {
  source          = "./modules/nginx"
  project_name    = var.project_name
  nginx_conf_path = "${path.module}/../nginx/${var.nginx_conf_file}"
  public_network  = module.network.public_network_name
  private_network = module.network.private_network_name
  external_port   = var.proxy_port

  providers = {
    docker = docker.local
  }
}
