Resources to deploy:

- This template deploys an Azure Kubernetes Service cluster configured for common enterprise usage.

- The AKS Cluster is deployed inside a private network

- Ingress network fronted by an Azure Application Gateway with a Web Application Firewall enabled.

- an Azure Container Reigstery instance is also deployed, and Managed Identity is leveraged to enable read access to the ACR instance from AKS.
