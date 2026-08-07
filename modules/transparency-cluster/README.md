# terraform-confium // transparency-cluster

Umbrella module for a full transparency deployment (log-server + monitor + witness). Currently the monitor and witness containers are not yet published to GHCR; use `modules/log-server` standalone for now.

## Usage

```hcl
module "transparency" {
  source = "confium/terraform-confium//modules/transparency-cluster"
}
```
