
data "docker_logs" "proxy" {
  depends_on      = [docker_container.proxy]
  name            = docker_container.proxy.name
  show_stdout     = true
  show_stderr     = true
  discard_headers = true
  logs_list_string_enabled = true
  details = true
}

resource "time_sleep" "wait_for_proxy_logs" {
  depends_on      = [docker_container.proxy]
  create_duration = "10s"
}

resource "null_resource" "verify_proxy_log" {
  depends_on = [data.docker_logs.proxy, time_sleep.wait_for_proxy_logs]
  count = var.run_healthcheck ? 1 : 0
  lifecycle {
    postcondition {
      condition = (
        length(data.docker_logs.proxy.logs_list_string) == 0 ||
        !can(regex("(?i)error", join("\n", data.docker_logs.proxy.logs_list_string)))
      )
      error_message = "Proxy Nginx container apresentou erros nos logs."
    }
  }
}