# terraform-confium // signerd

Deploys `confium-signerd` as a StatefulSet on Kubernetes.

## Usage

```hcl
module "signerd" {
  source           = "confium/terraform-confium//modules/signerd"
  coordinator_url  = "https://coordinator.internal:7000"
  replicas         = 3
}
```

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| namespace | string | confium-system | K8s namespace |
| replicas | number | 3 | signerd replicas (one share each) |
| image | string | ghcr.io/confium/signerd:latest | container image |
| coordinator_url | string | — | coordinator URL |
| share_storage_gb | number | 1 | PVC size |
| log_level | string | info | RUST_LOG |

## Outputs

| Name | Description |
|------|-------------|
| namespace | namespace deployed to |
| service_name | signerd service name |
| replicas | replicas deployed |
