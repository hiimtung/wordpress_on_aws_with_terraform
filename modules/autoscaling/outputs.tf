output "alb_dns" {
  value       = module.alb.lb_dns_name
  description = "Export lb dns name from alb's module"
}