
==Design==
===Architecture and Resources to deploy===
  1. Deploy an app service plan
  1. Deploy an app service - Linux Docker to run Nginx (from: "DOCKER|nginxdemos/hello")

===Files===
  1. terraform.tfvars
  1. main.tf 
  1. variables.tf
  1. resources.tf  

===execution===
  * terraform init
  * terraform plan -out plan.out
  * terraform apply plan.out
