output "network_id" {
  description = "Identificador unico de la red privada"
  value       = hcloud_network.this.id
}

output "network_name" {
  description = "Nombre asignado a la red"
  value       = hcloud_network.this.name
}

output "subnet_ip_range" {
  description = "Rango de la subred creada"
  value       = hcloud_network_subnet.this.ip_range
}
