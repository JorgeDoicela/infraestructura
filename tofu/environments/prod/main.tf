terraform {
  required_version = ">= 1.8.0"

  required_providers {
    # Ejemplo con Hetzner Cloud (el estandar habitual en Europa/Latam por coste y rendimiento)
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }

  # Descomentar al configurar el backend remoto seguro (ej. Cloudflare R2, AWS S3 o MinIO)
  # backend "s3" {
  #   bucket                      = "infra-terraform-state"
  #   key                         = "prod/terraform.tfstate"
  #   region                      = "auto"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  # }
}

provider "hcloud" {
  token = var.hcloud_token
}

# Llave SSH publica autorizada para aprovisionamiento inicial
resource "hcloud_ssh_key" "deploy" {
  name       = "deploy-key"
  public_key = var.ssh_public_key
}

# Red privada para aislar la comunicacion interna
resource "hcloud_network" "private_net" {
  name     = "internal-network"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "servers_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}

# Servidor base Debian Minimal
resource "hcloud_server" "prod_node" {
  name        = "srv-prod-01"
  server_type = var.server_type
  image       = "debian-12"
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.deploy.id]

  network {
    network_id = hcloud_network.private_net.id
    ip         = "10.0.1.10"
  }

  labels = {
    environment = "prod"
    managed_by  = "opentofu"
  }
}
