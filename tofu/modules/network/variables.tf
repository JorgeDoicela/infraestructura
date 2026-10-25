variable "network_name" {
  description = "Nombre de la red privada"
  type        = string
}

variable "ip_range" {
  description = "Rango CIDR para la red privada global"
  type        = string
  default     = "10.0.0.0/16"
}

variable "network_zone" {
  description = "Zona geografica de la red en Hetzner Cloud"
  type        = string
  default     = "eu-central"
}

variable "subnet_ip_range" {
  description = "Rango CIDR para la subred de servidores"
  type        = string
  default     = "10.0.1.0/24"
}

variable "labels" {
  description = "Etiquetas descriptivas para la red"
  type        = map(string)
  default     = {}
}
