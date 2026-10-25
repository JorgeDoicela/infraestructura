terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }

  # Backend S3 remoto corporativo para produccion
  # backend "s3" {
  #   bucket                      = "work-infra-tfstate"
  #   key                         = "prod/terraform.tfstate"
  #   region                      = "eu-central-1"
  # }
}

provider "hcloud" {
  token = var.hcloud_token
}

module "network" {
  source          = "../../../modules/network"
  network_name    = "work-net-prod"
  ip_range        = "10.30.0.0/16"
  subnet_ip_range = "10.30.1.0/24"
  labels = {
    context     = "work"
    environment = "prod"
  }
}

module "server" {
  source         = "../../../modules/compute"
  server_name    = "work-srv-prod-01"
  server_type    = var.server_type
  image          = "debian-12"
  location       = var.location
  ssh_public_key = var.ssh_public_key
  network_id     = module.network.network_id
  private_ip     = "10.30.1.10"
  environment    = "prod"
  labels = {
    context     = "work"
    environment = "prod"
  }
}
