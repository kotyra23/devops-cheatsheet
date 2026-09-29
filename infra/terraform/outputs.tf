output "app_url" {
  description = "URL Flask-приложения"
  value       = "http://localhost:${var.app_port}"
}

output "grafana_url" {
  description = "URL Grafana"
  value       = "http://localhost:${var.grafana_port}"
}

output "prometheus_url" {
  description = "URL Prometheus"
  value       = "http://localhost:${var.prometheus_port}"
}

output "alertmanager_url" {
  description = "URL Alertmanager"
  value       = "http://localhost:${var.alertmanager_port}"
}

output "cadvisor_url" {
  description = "URL cAdvisor"
  value       = "http://localhost:${var.cadvisor_port}"
}

output "ntfy_alerts_url" {
  description = "URL для просмотра алертов"
  value       = "https://ntfy.sh/nik-devops-cheatsheet-alerts"
}
