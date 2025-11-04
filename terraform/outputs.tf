output "frontend_url" {
  value = "http://localhost:${var.proxy_port}"
}

output "api_url" {
  value = "http://localhost:${var.proxy_port}/api"
}

output "dozzle_url" {
  value = "http://localhost:8086"
}

output "cadivsor_url" {
  value = "http://localhost:8085"
}