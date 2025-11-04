data "docker_logs" "backend" {
  depends_on               = [docker_container.backend]
  name                     = docker_container.backend.name
  show_stdout              = true
  show_stderr              = true
  discard_headers          = true
  logs_list_string_enabled = true
  details                  = true
}

resource "time_sleep" "wait_for_backend_logs" {
  depends_on      = [docker_container.backend]
  create_duration = "10s"
}

resource "null_resource" "verify_backend_log" {
  depends_on = [data.docker_logs.backend, time_sleep.wait_for_backend_logs]
  count      = var.run_healthcheck ? 1 : 0
  lifecycle {
    postcondition {
      condition = (
        length(data.docker_logs.backend.logs_list_string) == 0 ||
        !can(regex("(?i)error", join("\n", data.docker_logs.backend.logs_list_string)))
      )
      error_message = "Backend container apresentou erros nos logs."
    }
  }
}

# resource "local_file" "backend_logs_dump" {
#   depends_on = [data.docker_logs.backend, time_sleep.wait_for_backend_logs]
#   content    = join("\n", data.docker_logs.backend.logs_list_string)
#   filename   = "${path.module}/backend.logs.txt"
# }




