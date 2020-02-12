(1) Resources to deploy


- 1 jump box for login connection, with a public IP (ip1)

- a VMSS – virtual machine scale set.

- LB is inlcuded for the VMSS, with a frond end Public IP (ip2)

- install NGINX on the VMSS, then HTTP access from the public FQDN

- tag for all resources will be "staging"

- FQDN name will be generated randomly – the parameter will be saved in output file


(2) Steps


- Create the tfvars file to Azure authentication info

- Create a Terraform variable file

- Use a Terraform configuration file to define RG, VNET, Subnets and Public IP 

- Add code to the same Terraform configuration file to define VMSS

- Create a tf file to define a jump box 

- create an output file

- create a web.conf file to store NGINX code

- Apply the Terraform execution plan to create the Azure resources.
