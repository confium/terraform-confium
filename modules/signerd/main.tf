# Confium signerd — threshold signing daemon.
#
# Deploys signerd as a StatefulSet with PVC for share storage, a
# ServiceAccount with RBAC for the operator, and a NetworkPolicy that
# allows ingress only from the coordinator.

terraform {
  required_version = ">= 1.5"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

variable "namespace" {
  description = "Kubernetes namespace to deploy into."
  type        = string
  default     = "confium-system"
}

variable "replicas" {
  description = "Number of signerd replicas. Each replica holds one share of one or more threshold keys."
  type        = number
  default     = 3
}

variable "image" {
  description = "signerd image. Defaults to the latest from GHCR."
  type        = string
  default     = "ghcr.io/confium/signerd:latest"
}

variable "coordinator_url" {
  description = "URL of the confium-coordinator this signerd registers with."
  type        = string
}

variable "share_storage_gb" {
  description = "PVC size for share storage."
  type        = number
  default     = 1
}

variable "log_level" {
  description = "RUST_LOG value for signerd."
  type        = string
  default     = "info"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account" "signerd" {
  metadata {
    name      = "confium-signerd"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role" "signerd" {
  metadata { name = "confium-signerd" }
  rule {
    api_groups = [""]
    resources  = ["secrets", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "signerd" {
  metadata { name = "confium-signerd" }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.signerd.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.signerd.metadata[0].name
    namespace = kubernetes_namespace.this.metadata[0].name
  }
}

resource "kubernetes_stateful_set" "signerd" {
  metadata {
    name      = "confium-signerd"
    namespace = kubernetes_namespace.this.metadata[0].name
    labels    = { app = "confium-signerd" }
  }
  spec {
    service_name_name = "confium-signerd"
    replicas          = var.replicas
    selector { match_labels = { app = "confium-signerd" } }
    template {
      metadata { labels = { app = "confium-signerd" } }
      spec {
        service_account_name = kubernetes_service_account.signerd.metadata[0].name
        container {
          name  = "signerd"
          image = var.image
          env {
            name  = "COORDINATOR_URL"
            value = var.coordinator_url
          }
          env {
            name  = "RUST_LOG"
            value = var.log_level
          }
          volume_mount {
            name       = "shares"
            mount_path = "/etc/confium/shares"
          }
        }
      }
    }
    volume_claim_template {
      metadata { name = "shares" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources { requests = { storage = "${var.share_storage_gb}Gi" } }
      }
    }
  }
}

resource "kubernetes_service" "signerd" {
  metadata {
    name      = "confium-signerd"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  spec {
    selector = { app = "confium-signerd" }
    port {
      port        = 7000
      target_port = 7000
    }
  }
}

output "namespace"    { value = kubernetes_namespace.this.metadata[0].name }
output "service_name" { value = kubernetes_service.signerd.metadata[0].name }
output "replicas"     { value = var.replicas }
