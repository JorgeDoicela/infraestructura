variable "hcloud_token" {
  description = "Token de API de Hetzner Cloud para entorno de staging corporativo"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave SSH publica autorizada para staging"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExampleWorkStagingDeployKey work-staging@infra"
}

variable "location" {
  description = "Centro de datos de despliegue"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Tipo de servidor para staging"
  type        = string
  default     = "cpx21" # 3 vCPU AMD, 4 GB RAM
}
