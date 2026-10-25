terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }

  # Backend S3 remoto para proyectos personales (ej. Cloudflare R2 / AWS S3)
  # backend "s3" {
  #   bucket                      = "personal-infra-tfstate"
  #   key                         = "prod/terraform.tfstate"
  #   region                      = "auto"
  #   skip_credentials_validation = true
  #   skip_region_validation      = true
  # }
}

provider "hcloud" {
  token = var.hcloud_token
}

module "network" {
  source          = "../../../modules/network"
  network_name    = "personal-net-prod"
  ip_range        = "10.10.0.0/16"
  subnet_ip_range = "10.10.1.0/24"
  labels = {
    context     = "personal"
    environment = "prod"
  }
}

module "server" {
  source         = "../../../modules/compute"
  server_name    = "personal-srv-prod-01"
  server_type    = var.server_type
  image          = "debian-12"
  location       = var.location
  ssh_public_key = var.ssh_public_key
  network_id     = module.network.network_id
  private_ip     = "10.10.1.10"
  environment    = "prod"
  labels = {
    context     = "personal"
    environment = "prod"
  }
}
