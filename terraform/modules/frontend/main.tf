resource "docker_image" "frontend" {
  name = var.image_name
  build {
    context    = var.context_path
    dockerfile = "Dockerfile"
  }
  keep_locally = true
}

resource "docker_container" "frontend" {
  name  = "${var.project_name}-frontend"
  image = docker_image.frontend.name

  env = [
    "PUBLIC_API_BASE=/api"
  ]

  networks_advanced {
    name    = var.public_network
    aliases = ["frontend"]
  }

  restart  = "unless-stopped"
  must_run = true
}
