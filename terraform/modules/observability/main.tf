# cAdvisor – monitora containers Docker
resource "docker_container" "cadvisor" {
  name  = "${var.project_name}-cadvisor"
  image = "gcr.io/cadvisor/cadvisor:latest"

  ports {
    internal = 8080
    external = 8085
  }

  mounts {
    target = "/var/run"
    source = "/var/run"
    type   = "bind"
  }

  mounts {
    target = "/sys"
    source = "/sys"
    type   = "bind"
  }

  mounts {
    target = "/var/lib/docker"
    source = "/var/lib/docker"
    type   = "bind"
  }

  networks_advanced {
    name    = var.private_network
    aliases = ["cadvisor"]
  }
  networks_advanced {
    name    = var.public_network
    aliases = ["cadvisor"]
  }

  restart  = "unless-stopped"
  must_run = true
}

resource "docker_container" "dozzle" {
  name  = "${var.project_name}-dozzle"
  image = "amir20/dozzle:latest"

  ports {
    internal = 8080
    external = 8086
  }

  mounts {
    target = "/var/run/docker.sock"
    source = "/var/run/docker.sock"
    type   = "bind"
  }

  networks_advanced {
    name    = var.private_network
    aliases = ["dozzle"]
  }

  networks_advanced {
    name    = var.public_network
    aliases = ["dozzle"]
  }


  restart  = "unless-stopped"
  must_run = true
}

