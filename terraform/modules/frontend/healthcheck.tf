data "docker_logs" "frontend" {
  depends_on      = [docker_container.frontend]
  name            = docker_container.frontend.name
  show_stdout     = true
  show_stderr     = true
  discard_headers = true
  logs_list_string_enabled = true
  details = true
}

resource "time_sleep" "wait_for_frontend_logs" {
  depends_on      = [docker_container.frontend]
  create_duration = "10s"
}

resource "null_resource" "verify_frontend_log" {
  depends_on = [data.docker_logs.frontend, time_sleep.wait_for_frontend_logs]
  count = var.run_healthcheck ? 1 : 0
  lifecycle {
    postcondition {
      condition = (
        length(data.docker_logs.frontend.logs_list_string) == 0 ||
        !can(regex("(?i)error", join("\n", data.docker_logs.frontend.logs_list_string)))
      )
      error_message = "Frontend container apresentou erros nos logs."
    }
  }
}