# Minimal signerd deployment.
#
# Run: terraform init && terraform apply

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "signerd" {
  source          = "../../modules/signerd"
  coordinator_url = "https://coordinator.internal:7000"
}
