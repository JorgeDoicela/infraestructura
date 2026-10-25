terraform {
  required_version = ">= 1.8.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }
}

resource "hcloud_ssh_key" "this" {
  name       = "${var.server_name}-key"
  public_key = var.ssh_public_key
  labels     = var.labels
}

resource "hcloud_server" "this" {
  name        = var.server_name
  server_type = var.server_type
  image       = var.image
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.this.id]

  network {
    network_id = var.network_id
    ip         = var.private_ip
  }

  labels = merge(
    var.labels,
    {
      environment = var.environment
      managed_by  = "opentofu"
    }
  )
}
