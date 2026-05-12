output "db_address" {
  description = "Endpoint de RDS sin puerto"
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "Endpoint completo de RDS"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.this.db_name
}