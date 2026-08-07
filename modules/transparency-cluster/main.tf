# Confium transparency cluster: log-server + monitor + witness.
#
# Deploys a full transparency topology:
#   - 1 log-server (append-only)
#   - 1 monitor (watches log-server, gossips to other monitors)
#   - 1 witness (signs observed heads; can be deployed standalone)
#
# For production, split these into separate Terraform modules so each
# can be operated by a different team / in a different cluster.

terraform {
  required_version = ">= 1.5"
}

variable "namespace" { type = string default = "confium-system" }

module "log_server" {
  source          = "../log-server"
  namespace       = var.namespace
  log_storage_gb  = 50
}

# Monitor + witness would be additional module calls here; kept as TODO
# until those container images are built. For now this module exists
# as the umbrella; deploy log-server standalone via the log-server
# module for now.

output "log_server_service" { value = module.log_server.service_name }
