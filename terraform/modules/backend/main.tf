resource "docker_image" "backend" {
  name = var.image_name
  build {
    context    = var.context_path
    dockerfile = "Dockerfile"
  }
  keep_locally = true
}

resource "docker_container" "backend" {
  name  = "${var.project_name}-backend"
  image = docker_image.backend.name

  env = [
    "PORT=8080",
    "HOST=0.0.0.0",
    "DB_HOST=${var.db_host}",
    "DB_PORT=${var.db_port}",
    "DB_USER=${var.db_user}",
    "DB_PASS=${var.db_password}",
    "DB_NAME=${var.db_name}",
  ]

  networks_advanced {
    name    = var.private_network
    aliases = ["backend"]
  }

  restart  = "unless-stopped"
  must_run = true
}
