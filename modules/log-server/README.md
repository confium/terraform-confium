# terraform-confium // log-server

Deploys the Confium transparency log server.

## Usage

```hcl
module "log_server" {
  source = "confium/terraform-confium//modules/log-server"
  witnesses = [
    "https://witness1.example.com",
    "https://witness2.example.com",
  ]
  anchor_cadence_minutes = 30
}
```
