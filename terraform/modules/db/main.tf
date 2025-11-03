resource "docker_volume" "pgdata" {
  name = "${var.project_name}-pgdata"
}

resource "docker_image" "postgres" {
  name = "postgres:15.8"
  keep_locally = true
}

resource "docker_container" "db" {
  name  = "${var.project_name}-db"
  image = docker_image.postgres.name

  env = [
    "POSTGRES_DB=${var.db_name}",
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
  ]

  mounts {
    target = "/var/lib/postgresql/data"
    type   = "volume"
    source = docker_volume.pgdata.name
  }

  mounts {
    target = "/docker-entrypoint-initdb.d/init.sql"
    type   = "bind"
    source = "${var.init_sql_path}"
    read_only = true
  }

  networks_advanced {
    name    = var.private_network
    aliases = ["postgres"]
  }

  restart   = "unless-stopped"
  must_run  = true
}
