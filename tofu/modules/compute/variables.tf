variable "server_name" {
  description = "Nombre o hostname del servidor"
  type        = string
}

variable "server_type" {
  description = "Tipo de instancia / recursos de CPU y RAM"
  type        = string
  default     = "cpx11"
}

variable "image" {
  description = "Distribucion base del sistema operativo"
  type        = string
  default     = "debian-12"
}

variable "location" {
  description = "Centro de datos del proveedor"
  type        = string
  default     = "fsn1"
}

variable "ssh_public_key" {
  description = "Contenido de la llave publica SSH autorizada"
  type        = string
}

variable "network_id" {
  description = "Identificador de la red privada interna"
  type        = string
}

variable "private_ip" {
  description = "Direccion IP estatica dentro de la red privada"
  type        = string
}

variable "environment" {
  description = "Ambiente (prod, staging)"
  type        = string
}

variable "labels" {
  description = "Etiquetas descriptivas para el servidor"
  type        = map(string)
  default     = {}
}
