resource "docker_image" "nginx" {
  name = var.image_name
  build {
    context    = var.context_path
    dockerfile = "Dockerfile"
    build_args = {
      CONFIG_HASH = filesha256(var.nginx_conf_path)
    }
  }
  keep_locally = true
}

resource "docker_container" "proxy" {
  name  = "${var.project_name}-proxy"
  image = docker_image.nginx.name

  mounts {
    type      = "bind"
    target    = "/etc/nginx/nginx.conf"
    source    = abspath(var.nginx_conf_path)
    read_only = true
  }

  ports {
    internal = 80
    external = var.external_port
    protocol = "tcp"
  }

  networks_advanced {
    name    = var.public_network
    aliases = ["proxy"]
  }

  networks_advanced {
    name = var.private_network
  }

  restart  = "unless-stopped"
  must_run = true

}
