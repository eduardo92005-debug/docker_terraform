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

  env = var.env_vars

  networks_advanced {
    name    = var.private_network
    aliases = ["backend"]
  }

  restart  = "unless-stopped"
  must_run = true

  healthcheck {
    test         = ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:8080/api"]
    interval     = "5s"
    timeout      = "2s"
    start_period = "5s"
    retries      = 5
  }

}
