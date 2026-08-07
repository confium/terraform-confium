# Confium transparency log server.
#
# Deploys log-server as a StatefulSet with PVC for the log database.
# Exposes :7878 for client append/prove/verify. Configured via
# ConfigMap for log identity, witnesses, and anchoring cadence.

terraform {
  required_version = ">= 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

variable "namespace"        { type = string default = "confium-system" }
variable "image"            { type = string default = "ghcr.io/confium/log-server:latest" }
variable "log_storage_gb"   { type = number default = 50 }
variable "witnesses" {
  description = "List of witness endpoints to gossip heads to."
  type        = list(string)
  default     = []
}
variable "anchor_cadence_minutes" {
  description = "Cadence for OTS Bitcoin anchoring."
  type        = number
  default     = 60
}

resource "kubernetes_config_map" "log_server" {
  metadata { name = "confium-log-server" }
  data = {
    "log-server.toml" = <<-EOT
      [log]
      identity = "confium-default"
      data_path = "/var/lib/confium/log.db"

      [gossip]
      witnesses = ${jsonencode(var.witnesses)}

      [anchor]
      cadence_minutes = ${var.anchor_cadence_minutes}
      calendar_url = "https://a.pool.opentimestamps.org"
    EOT
  }
}

resource "kubernetes_stateful_set" "log_server" {
  metadata { name = "confium-log-server" }
  spec {
    service_name_name = "confium-log-server"
    replicas          = 1
    template {
      metadata { labels = { app = "confium-log-server" } }
      spec {
        container {
          name  = "log-server"
          image = var.image
          volume_mount {
            name       = "log-data"
            mount_path = "/var/lib/confium"
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/confium"
          }
        }
        volume { name = "config"
          config_map_name = kubernetes_config_map.log_server.metadata[0].name
        }
      }
    }
    volume_claim_template {
      metadata { name = "log-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources { requests = { storage = "${var.log_storage_gb}Gi" } }
      }
    }
  }
}

resource "kubernetes_service" "log_server" {
  metadata { name = "confium-log-server" }
  spec {
    selector = { app = "confium-log-server" }
    port     { port = 7878 target_port = 7878 }
  }
}

output "service_name" { value = kubernetes_service.log_server.metadata[0].name }
