# wordpress-on-aws-with-terraform
##### TODO
- [ ] checkov
- [ ] ludicrousdb
##### Description

This project is to create a high avaibility wordpress web-server on AWS base on Terraform - an IaC platform.<br>

##### Prerequisites

- Terraform v1.2.2 or later <https://www.terraform.io/downloads/>
- AWS CLI ver2 <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html/>
- Shell (SH), Powershell (if you are using Windows)

##### How to contribute

Please follow this [link](https://github.com/tnx-journey-to-cloud/wordpress-terraform-project/blob/main/howtocontribute.md)

##### How to install & run

- Install all prerequisites above
- Deploy<br>
    <code>cd ~/wordpress-on-aws-with-terraform/main</code><br>
    <code>terraform init</code><br>
    <code>terraform plan</code><br>
    <code>terraform apply</code><br>
- Destroy<br>
    <code>terraform destroy</code>
##### Architecture    
![9c97a8390e9dccc3958c (1)_auto_x2](https://i.imgur.com/6aRdaTf.jpg)
##### Directory structure
```
├───📁 .github/
│   └───📁 workflows/
│       ├───📄 notify.yaml
│       └───📄 infra-cost.yaml
│       └───📄 release.yaml
├───📁 modules/
│   ├───📁 autoscaling/
│   │   ├───📄 main.tf
│   │   ├───📄 outputs.tf
│   │   ├───📄 userdata.tftpl
│   │   └───📄 variables.tf
│   ├───📁 database/
│   │   ├───📁 resources/
│   │   │   └───...
│   │   ├───📄 db-rotate.tf
│   │   ├───📄 local.tf
│   │   ├───📄 main.tf
│   │   ├───📄 output.tf
│   │   └───📄 variables.tf
│   ├───📁 efs/
│   │   ├───📄 main.tf
│   │   ├───📄 outputs.tf
│   │   └───📄 variables.tf
│   ├───📁 elasticache/
│   │   ├───📄 main.tf
│   │   ├───📄 outputs.tf
│   │   └───📄 variables.tf
│   ├───📁 networking/
│   │   ├───📄 main.tf
│   │   ├───📄 outputs.tf
│   │   └───📄 variables.tf
│   └───📁 s3/
│       ├───📄 main.tf
│       ├───📄 outputs.tf
│       └───📄 variables.tf
├───📁 main/
│   ├───📄 locals.tf
│   ├───📄 main.tf
│   ├───📄 outputs.tf
│   ├───📄 provider.tf
│   ├───📄 README.md
│   └───📄 variables.tf
├───📄 .editorconfig
├───📄 .gitignore
├───📄 howtocontribute.md
├───📄 README.md
└───📄 repos.yaml

```
