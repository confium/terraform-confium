# terraform-confium

Terraform modules for deploying [Confium](https://www.confium.org/) to Kubernetes.

## Modules

| Module | What |
|--------|------|
| [`modules/signerd`](./modules/signerd) | Threshold signing daemon (StatefulSet) |
| [`modules/log-server`](./modules/log-server) | RFC 6962 transparency log server |
| [`modules/transparency-cluster`](./modules/transparency-cluster) | Log server + monitor + witness (umbrella) |

## Usage

```hcl
module "signerd" {
  source           = "confium/terraform-confium//modules/signerd"
  coordinator_url  = "https://coordinator.internal:7000"
  replicas         = 3
}

module "log_server" {
  source = "confium/terraform-confium//modules/log-server"
}
```

See [`examples/`](./examples) for runnable end-to-end configs.

## Requirements

- Terraform >= 1.5
- Kubernetes provider >= 2.30
- A Kubernetes cluster with the Confium operator installed (see [`deploy/k8s/bundle.yaml`](https://github.com/confium/confium/blob/main/deploy/k8s/bundle.yaml))

## Validation

CI runs `terraform fmt -check`, `terraform validate`, and `terraform plan` against a kind cluster on every PR.

## License

BSD-2-Clause, same as Confium itself.
