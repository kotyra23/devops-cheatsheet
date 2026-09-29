variable "app_port" {
  description = "Порт для Flask-приложения"
  type        = number
  default     = 5000
}

variable "prometheus_port" {
  description = "Порт для Prometheus"
  type        = number
  default     = 9090
}

variable "grafana_port" {
  description = "Порт для Grafana"
  type        = number
  default     = 3000
}

variable "alertmanager_port" {
  description = "Порт для Alertmanager"
  type        = number
  default     = 9093
}

variable "cadvisor_port" {
  description = "Порт для cAdvisor"
  type        = number
  default     = 8080
}

variable "grafana_admin_password" {
  description = "Пароль администратора Grafana"
  type        = string
  default     = "admin"
  sensitive   = true
}
