### Azure Virtual Machine Setup with Terraform

This README outlines the steps for setting up a virtual machine in Azure using Terraform. It includes creating a resource group, virtual network, subnet, public IP, network interface, and deploying a Linux virtual machine with various software installations.

## Prerequisites

- An Azure account
- Terraform installed on your machine
- An SSH key pair for secure access to the VM (generate one using `ssh-keygen` if you don't have one)

## What Gets Installed

The Terraform script provisions the following:

### Azure Resources:

- Resource Group
- Virtual Network
- Subnet
- Public IP
- Network Interface

### Linux VM (Ubuntu 22.04) with:

- `dotnet-sdk-6.0`
- `git`
- Azure CLI
- Microsoft SQL Server Tools (`mssql-tools`)
- UnixODBC Developer Package (`unixodbc-dev`)
- A VSTS agent setup for Azure DevOps integration

## Post-Installation

After Terraform successfully applies the configuration, you can:

- Access your VM via SSH using the public IP.
- Manage resources through the Azure portal or Azure CLI.
- Configure further settings or install additional software on your VM as needed.

## Troubleshooting

If you encounter issues during the Terraform apply process:

- Ensure that your Azure credentials are correctly set up.
- Check that all variable values in `variables.tf` are correct.
- Review Terraform's output for specific error messages.

For more specific help, refer to Azure's and Terraform's documentation or their respective community forums.