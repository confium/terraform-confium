# Minimal transparency cluster.

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "transparency" {
  source = "../../modules/transparency-cluster"
}
