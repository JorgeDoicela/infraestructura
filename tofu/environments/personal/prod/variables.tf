variable "hcloud_token" {
  description = "Token de API de Hetzner Cloud para proyectos personales"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "Llave SSH publica personal para provisionamiento inicial"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePersonalDeployKey personal@infra"
}

variable "location" {
  description = "Centro de datos de despliegue"
  type        = string
  default     = "fsn1"
}

variable "server_type" {
  description = "Tipo de servidor para cargas personales"
  type        = string
  default     = "cpx11"
}
