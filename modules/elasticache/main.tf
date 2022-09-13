resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project}-memcached-subnetgroup"
  subnet_ids = var.subnet_ids
}
resource "aws_elasticache_cluster" "this" {
  cluster_id           = "${var.project}-memcached-cluster"
  engine_version       = var.engine_version
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = var.security_group_ids
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = var.parameter_group_name
  port                 = var.port
}
