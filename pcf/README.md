# PCF Azure Resource Manager (ARM) Templates

This repo contains ARM templates that help operators deploy Ops Manager Director for Pivotal Cloud Foundry (PCF). 

It also feature a Powershell Script to create required Storage Accounts, Blobs and Tables.
It Downloads the OpsManager Image and Creates the OpsManager Instance

For more information, see the [Launching an Ops Manager Director Instance with an ARM Template](https://docs.pivotal.io/pivotalcf/customizing/azure-arm-template.html) topic.


#Deploying Opsman 


# Filling in Configuration  


Subscription ID
can't be blank

Tenant ID
can't be blank

Application ID
can't be blank

Client Secret
can't be blank

Resource Group Name
can't be blank

BOSH Storage Account Name
can't be blank

Cloud Storage Type
 Use Managed Disks
Storage Account Type

 Use Storage Accounts
Deployments Storage Account Name

Default Security Group

SSH Public Key  
can't be blank

SSH Private Key
can't be blank  

Azure Environment

*Azure Stack*  
Tenant Management Resource Endpoint
```
(get-azurermcontext).Environment.ActiveDirectoryServiceEndpointResourceId
```

Domain

Authentication

Azure Stack Endpoint Prefix

Azure Stack CA Certificate

```
(get-azurermcontext).Environment.ActiveDirectoryServiceEndpointResourceId
```