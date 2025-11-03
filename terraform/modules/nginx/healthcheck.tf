data "docker_logs" "nginx" {
  depends_on      = [docker_container.nginx]
  name            = docker_container.nginx.name
  show_stdout     = true
  show_stderr     = true
  discard_headers = true
  logs_list_string_enabled = true
  details = true
}

resource "time_sleep" "wait_for_nginx_logs" {
  depends_on      = [docker_container.nginx]
  create_duration = "10s"
}

resource "null_resource" "verify_nginx_log" {
  depends_on = [data.docker_logs.nginx, time_sleep.wait_for_nginx_logs]

  lifecycle {
    postcondition {
      condition = (
        length(data.docker_logs.nginx.logs_list_string) == 0 ||
        !can(regex("(?i)error", join("\n", data.docker_logs.nginx.logs_list_string)))
      )
      error_message = "nginx container apresentou erros nos logs."
    }
  }
}