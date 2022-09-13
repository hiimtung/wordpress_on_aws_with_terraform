output "cluster_address" {
  value = aws_elasticache_cluster.this.cluster_address
}
output "cluster_endpoint" {
  value = aws_elasticache_cluster.this.configuration_endpoint
}

