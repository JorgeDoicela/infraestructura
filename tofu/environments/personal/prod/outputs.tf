output "server_public_ip" {
  description = "Direccion IPv4 publica del servidor personal"
  value       = module.server.public_ipv4
}

output "server_private_ip" {
  description = "Direccion IPv4 privada del servidor personal"
  value       = module.server.private_ipv4
}

output "server_status" {
  description = "Estado de la instancia personal"
  value       = module.server.status
}
