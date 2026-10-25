output "server_id" {
  description = "Identificador unico de la instancia"
  value       = hcloud_server.this.id
}

output "server_name" {
  description = "Hostname de la instancia"
  value       = hcloud_server.this.name
}

output "public_ipv4" {
  description = "Direccion IPv4 publica de la instancia"
  value       = hcloud_server.this.ipv4_address
}

output "private_ipv4" {
  description = "Direccion IPv4 en la red privada interna"
  value       = var.private_ip
}

output "status" {
  description = "Estado de ejecucion del servidor"
  value       = hcloud_server.this.status
}
