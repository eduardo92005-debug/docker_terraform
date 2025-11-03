resource "docker_image" "nginx" {
  name = "nginx:1.27-alpine"
  keep_locally = true
}

resource "docker_container" "proxy" {
  name  = "${var.project_name}-proxy"
  image = docker_image.nginx.name

  mounts {
    type   = "bind"
    target = "/etc/nginx/nginx.conf"
    source = var.nginx_conf_path
    read_only = true
  }

  ports {
    internal = 8080
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
