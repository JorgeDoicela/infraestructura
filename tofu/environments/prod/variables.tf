variable "hcloud_token" {
  description = "Token de API del proveedor Hetzner Cloud (Definir via variable de entorno TF_VAR_hcloud_token)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_public_key" {
  description = "Contenido de la llave publica SSH para acceso inicial al servidor"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyPlaceholder deploy@infra"
}

variable "location" {
  description = "Centro de datos de despliegue"
  type        = string
  default     = "fsn1" # Falkenstein, Alemania
}

variable "server_type" {
  description = "Tamano y tipo de CPU del servidor virtual"
  type        = string
  default     = "cpx11" # 2 vCPU AMD, 2 GB RAM
}
