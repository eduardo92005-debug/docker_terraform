output "frontend_url" {
  value = "http://localhost:${var.proxy_port}"
}

output "api_url" {
  value = "http://localhost:${var.proxy_port}/api"
}