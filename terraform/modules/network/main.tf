resource "docker_network" "public" {
  name     = "${var.project_name}-net-public"
  driver   = "bridge"
  internal = false
}

resource "docker_network" "private" {
  name     = "${var.project_name}-net-private"
  driver   = "bridge"
  internal = true
}
