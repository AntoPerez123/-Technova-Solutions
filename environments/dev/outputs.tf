# =========================
# VPC outputs
# =========================
output "vpc_id" {
  description = "ID de la VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "Lista de subnets publicas"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Lista de subnets privadas"
  value       = module.vpc.private_subnets
}

# =========================
# Security Groups outputs
# =========================
output "sg_alb_id" {
  description = "Security Group del ALB"
  value       = module.security_groups.sg_alb_id
}

output "sg_ec2_id" {
  description = "Security Group de EC2"
  value       = module.security_groups.sg_ec2_id
}

output "sg_rds_id" {
  description = "Security Group de RDS"
  value       = module.security_groups.sg_rds_id
}

# =========================
# ECR outputs
# =========================
output "ecr_repository_urls" {
  description = "URLs de los repositorios ECR"
  value       = module.ecr.repository_urls
}

# =========================
# ALB outputs
# =========================
output "alb_dns_name" {
  description = "DNS del ALB"
  value       = module.alb.alb_dns_name
}

output "tg_frontend_arn" {
  description = "ARN del target group frontend"
  value       = module.alb.tg_frontend_arn
}

output "tg_backend_arn" {
  description = "ARN del target group backend"
  value       = module.alb.tg_backend_arn
}

# =========================
# RDS outputs
# =========================
output "db_address" {
  description = "Endpoint de RDS sin puerto"
  value       = module.rds.db_address
}