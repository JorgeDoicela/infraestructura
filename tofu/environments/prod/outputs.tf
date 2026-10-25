output "server_public_ip" {
  description = "Direccion IPv4 publica del servidor aprovisionado"
  value       = hcloud_server.prod_node.ipv4_address
}

output "server_private_ip" {
  description = "Direccion IPv4 en la red privada interna"
  value       = "10.0.1.10"
}

output "server_status" {
  description = "Estado reportado por la API del servidor"
  value       = hcloud_server.prod_node.status
}
