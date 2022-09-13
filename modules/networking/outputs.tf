output "vpc_id" {
  value = module.vpc.vpc_id
}
output "vpc" {
  value       = module.vpc
  description = "Export values of vpc's module"
}
output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "Export value of public subnets"
}
output "ec2_sg" {
  value       = module.ec2_sg.security_group_id
  description = "Export sg id for ec2s from ec2_sg's module"
}
output "alb_sg" {
  value       = module.alb_sg.security_group_id
  description = "Export sg id for alb from alb_sg's module"
}
output "db_sg" {
  value       = module.db_sg.security_group_id
  description = "Export sg id for db from db_sg's module"
}
output "efs_sg" {
  value       = module.efs_sg.security_group_id
  description = "Export sg id for efs from efs_sg's module"
}
output "cache_sg" {
  value       = module.cache_sg.security_group_id
  description = "Export sg id for elastic cache from cache_sg's module"
}