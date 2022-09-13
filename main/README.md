<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_autoscaling"></a> [autoscaling](#module\_autoscaling) | ../modules/autoscaling | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ../modules/cloudfront | n/a |
| <a name="module_database"></a> [database](#module\_database) | ../modules/database | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | ../modules/efs | n/a |
| <a name="module_elasticache"></a> [elasticache](#module\_elasticache) | ../modules/elasticache | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | ../modules/kms | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ../modules/networking | n/a |
| <a name="module_s3_log_bucket"></a> [s3\_log\_bucket](#module\_s3\_log\_bucket) | ../modules/s3 | n/a |
| <a name="module_s3_static"></a> [s3\_static](#module\_s3\_static) | ../modules/s3 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_resourcegroups_group.resource_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [random_string.bar](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.foo](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |
| [aws_iam_policy_document.inline_policy_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.inline_policy_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.instance_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | Number of ASG's instances initialized | `number` | `2` | no |
| <a name="input_asg_iam_instance_profile"></a> [asg\_iam\_instance\_profile](#input\_asg\_iam\_instance\_profile) | Iam role attached to ASG instance | `string` | `"S3-CF-SSM-role"` | no |
| <a name="input_asg_instance_type"></a> [asg\_instance\_type](#input\_asg\_instance\_type) | Instance type of ASG | `string` | `"t2.micro"` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | maximum number of ASG's instances | `number` | `2` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | minimum number of ASG's instances | `number` | `2` | no |
| <a name="input_asg_wp_email"></a> [asg\_wp\_email](#input\_asg\_wp\_email) | Wordpress admin's email | `string` | `"admin@example.com"` | no |
| <a name="input_asg_wp_password"></a> [asg\_wp\_password](#input\_asg\_wp\_password) | Wordpress admin's password | `string` | `"Zxcvb!@#%"` | no |
| <a name="input_asg_wp_username"></a> [asg\_wp\_username](#input\_asg\_wp\_username) | Wordpress admin's username | `string` | `"wordpressadmin"` | no |
| <a name="input_cache_engine"></a> [cache\_engine](#input\_cache\_engine) | Elastic cache | `string` | `"memcached"` | no |
| <a name="input_cache_engine_version"></a> [cache\_engine\_version](#input\_cache\_engine\_version) | n/a | `string` | `"1.6.12"` | no |
| <a name="input_cache_node_type"></a> [cache\_node\_type](#input\_cache\_node\_type) | n/a | `string` | `"cache.t2.micro"` | no |
| <a name="input_cache_num_cache_nodes"></a> [cache\_num\_cache\_nodes](#input\_cache\_num\_cache\_nodes) | n/a | `number` | `1` | no |
| <a name="input_cache_parameter_group_name"></a> [cache\_parameter\_group\_name](#input\_cache\_parameter\_group\_name) | n/a | `string` | `"default.memcached1.6"` | no |
| <a name="input_cache_port"></a> [cache\_port](#input\_cache\_port) | n/a | `number` | `11211` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | Allocated storage. RDS only | `number` | `20` | no |
| <a name="input_db_cluster_size"></a> [db\_cluster\_size](#input\_db\_cluster\_size) | Number of instance for Aurora cluster, ignore if use RDS | `number` | `2` | no |
| <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine) | n/a | `string` | `"aurora-mysql"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | n/a | `string` | `"db.t2.small"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | n/a | `string` | `"wordpressdb"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | n/a | `string` | `"doesnotmatter"` | no |
| <a name="input_db_password_rotation_days"></a> [db\_password\_rotation\_days](#input\_db\_password\_rotation\_days) | Password RDS rotation day | `number` | `30` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | n/a | `string` | `"admin"` | no |
| <a name="input_enabled_aurora"></a> [enabled\_aurora](#input\_enabled\_aurora) | Set true if use Aurora. Default is False | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Define the environment of resource, use for tagging | `string` | `"product"` | no |
| <a name="input_lt_ami_name"></a> [lt\_ami\_name](#input\_lt\_ami\_name) | n/a | `list(string)` | <pre>[<br>  "amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2"<br>]</pre> | no |
| <a name="input_lt_ami_owner"></a> [lt\_ami\_owner](#input\_lt\_ami\_owner) | n/a | `list(string)` | <pre>[<br>  "137112412989"<br>]</pre> | no |
| <a name="input_lt_key_name"></a> [lt\_key\_name](#input\_lt\_key\_name) | n/a | `string` | `"wp-keypair"` | no |
| <a name="input_nw_public_subnets"></a> [nw\_public\_subnets](#input\_nw\_public\_subnets) | List of Public subnets | `list(string)` | <pre>[<br>  "172.16.2.0/23",<br>  "172.16.4.0/23",<br>  "172.16.6.0/23"<br>]</pre> | no |
| <a name="input_nw_vpc_cidr"></a> [nw\_vpc\_cidr](#input\_nw\_vpc\_cidr) | VPC CIDR | `string` | `"172.16.0.0/16"` | no |
| <a name="input_project"></a> [project](#input\_project) | Project name, use for tagging and naming resource | `string` | `"wptf"` | no |
| <a name="input_region"></a> [region](#input\_region) | General | `string` | `"ap-southeast-1"` | no |
| <a name="input_s3_acl"></a> [s3\_acl](#input\_s3\_acl) | n/a | `string` | `"private"` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 | `string` | `"wordpress-s3-terraform"` | no |
| <a name="input_ssh_whitelist"></a> [ssh\_whitelist](#input\_ssh\_whitelist) | Whitelist IP for SSH connection to EC2 instance | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_domain"></a> [acm\_certificate\_domain](#output\_acm\_certificate\_domain) | n/a |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | n/a |
| <a name="output_elasticache_endpoint"></a> [elasticache\_endpoint](#output\_elasticache\_endpoint) | n/a |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | n/a |
| <a name="output_origin_s3_bucket"></a> [origin\_s3\_bucket](#output\_origin\_s3\_bucket) | n/a |
| <a name="output_s3_log_bucket"></a> [s3\_log\_bucket](#output\_s3\_log\_bucket) | n/a |
<!-- END_TF_DOCS -->