![This is an image](https://www.cloud-architect.fr/wp-content/uploads/2020/09/hashicorp-terraform-with-microsoft-azure-1-638.jpg)



# WeightTracker-application


The manual infrastructure of the Weight Tracker application builds on Terraform code Project Overview.
This project was created as part of DevOps Bootcamp to challenge and learn to resolve Terraform & azure issues in code.
Part of access credentials has been ruled by Okta.
If you want to use this code I recommend you to open Okta free accaunt.

# Prerequisites:

Configure a Linux virtual machine and PostgresSQL in Azure using Terraform
Article tested with the following Terraform and Terraform provider versions:
- 1 Terraform >= 0.12.x
- 2 Azure = "~>2.0"


**Azure subscription: 
If you don't have an Azure subscription, create a free account before you begin.**
https://azure.microsoft.com/en-us/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio


**Configure Terraform: If you haven't already done so, Install Terraform**
https://www.terraform.io/downloads


**Configure Terraform in Azure Cloud Shell with Bash**
https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash


**Configure Terraform in Azure Cloud Shell with PowerShell**
https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell


**Configure Terraform in Windows with Bash**
https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash


**Configure Terraform in Windows with PowerShell**
https://docs.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell

# The topology of the project

![This is an image](https://bootcamp.rhinops.io/images/week-6-envs.png)


# Project overview

- 1 Create a directory in which to test the sample Terraform code and make it the current directory.

- 2 Create a file named main.tf and insert the following code:

- 3 Create a file named providers.tf and insert the following code:

- 4 Create a file named variables.tf and insert the following code:

- 5 Create a file named output.tf and insert the following code:

# Initialize Terraform
Run terraform init to initialize the Terraform deployment. This command downloads the Azure modules required to manage your Azure resources: 
- terraform init
 

# Run terraform plan to create an execution plan: 
Create a Terraform execution plan: 
- terraform plan -out main.tfplan

Key points:

- The terraform plan command creates an execution plan, but doesn't execute it. Instead, it determines what actions are necessary to create the configuration specified in your configuration files. This pattern allows you to verify whether the execution plan matches your expectations before making any changes to actual resources.
- The optional -out parameter allows you to specify an output file for the plan. Using the -out parameter ensures that the plan you reviewed is exactly what is applied.
- To read more about persisting execution plans and security, see the security warning section.

# Apply a Terraform execution plan
Run terraform apply to apply the execution plan to your cloud infrastructure.
- terraform apply main.tfplan

Key points:

- The terraform apply command above assumes you previously ran terraform plan -out main.tfplan.
- If you specified a different filename for the -out parameter, use that same filename in the call to terraform apply.
- If you didn't use the -out parameter, simply call terraform apply without any parameters.

**All code stored in main repo**

Feel free to clone and modify this code ))
