output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "tg_frontend_arn" {
  description = "ARN del Target Group del frontend"
  value       = aws_lb_target_group.frontend.arn
}

output "tg_backend_arn" {
  description = "ARN del Target Group del backend"
  value       = aws_lb_target_group.backend.arn
}