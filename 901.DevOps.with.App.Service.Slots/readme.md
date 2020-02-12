(1) Purpose and Expected Results


- Deployment of the apps are done through Github to Azure

- Use Azure deployment slots to swap between different versions of app. – One app is hosted in a production slot. The second app is hosted in a staging slot.

- After you configure your deployment slots, you use Terraform to swap between the two slots as needed.


(2) Steps


- Create Azure App services using Terraform

- Fork the test project in Github

- Deploy from GitHub to your deployment slots

- Test the app deployments

- Swap the two deployment slots
