terraform {
  required_version = ">= 1.8.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45.0"
    }
  }

  # Backend S3 remoto corporativo para staging
  # backend "s3" {
  #   bucket                      = "work-infra-tfstate"
  #   key                         = "staging/terraform.tfstate"
  #   region                      = "eu-central-1"
  # }
}

provider "hcloud" {
  token = var.hcloud_token
}

module "network" {
  source          = "../../../modules/network"
  network_name    = "work-net-staging"
  ip_range        = "10.20.0.0/16"
  subnet_ip_range = "10.20.1.0/24"
  labels = {
    context     = "work"
    environment = "staging"
  }
}

module "server" {
  source         = "../../../modules/compute"
  server_name    = "work-srv-staging-01"
  server_type    = var.server_type
  image          = "debian-12"
  location       = var.location
  ssh_public_key = var.ssh_public_key
  network_id     = module.network.network_id
  private_ip     = "10.20.1.10"
  environment    = "staging"
  labels = {
    context     = "work"
    environment = "staging"
  }
}
