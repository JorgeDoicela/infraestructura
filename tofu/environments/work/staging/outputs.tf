output "server_public_ip" {
  description = "Direccion IPv4 publica del servidor de staging"
  value       = module.server.public_ipv4
}

output "server_private_ip" {
  description = "Direccion IPv4 privada del servidor de staging"
  value       = module.server.private_ipv4
}

output "server_status" {
  description = "Estado de la instancia de staging"
  value       = module.server.status
}
