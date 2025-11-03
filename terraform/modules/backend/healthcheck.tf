data "docker_logs" "backend" {
  depends_on      = [docker_container.backend]
  name            = docker_container.backend.name
  show_stdout     = true
  show_stderr     = true
  tail            = "100"
  discard_headers = true
}

resource "null_resource" "verify_backend_log" {
  depends_on = [data.docker_logs.backend]

  lifecycle {
    postcondition {
      condition     = can(regex("(?i)error", join("\n", data.docker_logs.backend.logs_list_string)))
      error_message = "Backend container apresentou erros nos logs."
    }
  }
}



