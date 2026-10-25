variable "hcloud_token" {
  description = "Token de API de Hetzner Cloud para entorno de produccion corporativo"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave SSH publica autorizada para produccion corporativa"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleWorkProdDeployKey work-prod@infra"
}

variable "location" {
  description = "Centro de datos de despliegue"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Tipo de servidor para produccion"
  type        = string
  default     = "cpx31" # 4 vCPU AMD, 8 GB RAM
}
