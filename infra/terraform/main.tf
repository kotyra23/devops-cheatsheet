terraform {
  required_version = ">= 1.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_network" "cheatsheet_net" {
  name   = "cheatsheet_net"
  driver = "bridge"
}

resource "docker_volume" "sqlite_data" {
  name = "cheatsheet_sqlite_data"
}

resource "docker_volume" "prometheus_data" {
  name = "cheatsheet_prometheus_data"
}

resource "docker_volume" "grafana_data" {
  name = "cheatsheet_grafana_data"
}

resource "docker_image" "app" {
  name = "devops-cheatsheet-app"
  build {
    context    = "${path.module}/../../"
    dockerfile = "Dockerfile"
  }
}

resource "docker_container" "app" {
  name  = "cheatsheet_app"
  image = docker_image.app.image_id

  ports {
    internal = 5000
    external = 5000
  }

  env = [
    "FLASK_ENV=production",
    "DATABASE_PATH=/app/data/cheatsheet.db"
  ]

  volumes {
    volume_name    = docker_volume.sqlite_data.name
    container_path = "/app/data"
  }

  networks_advanced {
    name = docker_network.cheatsheet_net.name
  }

  restart = "unless-stopped"

  healthcheck {
    test         = ["CMD", "curl", "-f", "http://localhost:5000/health"]
    interval     = "30s"
    timeout      = "10s"
    retries      = 3
    start_period = "10s"
  }
}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "cheatsheet_prometheus"
  image = docker_image.prometheus.image_id

  ports {
    internal = 9090
    external = 9090
  }

  volumes {
    host_path      = "${path.module}/../docker/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    host_path      = "${path.module}/../docker/alert_rules.yml"
    container_path = "/etc/prometheus/alert_rules.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus"
  ]

  networks_advanced {
    name = docker_network.cheatsheet_net.name
  }
}

resource "docker_image" "alertmanager" {
  name = "prom/alertmanager:latest"
}

resource "docker_container" "alertmanager" {
  name  = "cheatsheet_alertmanager"
  image = docker_image.alertmanager.image_id

  ports {
    internal = 9093
    external = 9093
  }

  volumes {
    host_path      = "${path.module}/../docker/alertmanager.yml"
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }

  command = [
    "--config.file=/etc/alertmanager/alertmanager.yml"
  ]

  networks_advanced {
    name = docker_network.cheatsheet_net.name
  }
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "cheatsheet_grafana"
  image = docker_image.grafana.image_id

  ports {
    internal = 3000
    external = 3000
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=admin"
  ]

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  networks_advanced {
    name = docker_network.cheatsheet_net.name
  }
}

resource "docker_image" "cadvisor" {
  name = "gcr.io/cadvisor/cadvisor:latest"
}

resource "docker_container" "cadvisor" {
  name  = "cheatsheet_cadvisor"
  image = docker_image.cadvisor.image_id

  ports {
    internal = 8080
    external = 8080
  }

  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }

  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = true
  }

  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }

  volumes {
    host_path      = "/var/lib/docker/"
    container_path = "/var/lib/docker"
    read_only      = true
  }

  networks_advanced {
    name = docker_network.cheatsheet_net.name
  }
}
