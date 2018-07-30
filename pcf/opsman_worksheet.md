# Configuring OpsMANAGER
after successfull deploying OpsMANAGER 


## Filling in Configuration  


Subscription ID  
*can't be blank*
```
(Get-AzureRMSubscription).id  
```


Tenant ID  
*can't be blank*
```
(Get-AzureRMSubscription).TenantID  
```

Application ID  
*can't be blank*  
[See here how to create a Service Principal in AzureAD](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#create-an-azure-active-directory-application)  
Kickstart Users can use 01_create_service_principal.ps1


Client Secret  
*can't be blank*  

Resource Group Name  
*can't be blank*  

BOSH Storage Account Name  
*can't be blank*  
See Output from Deployment
Cloud Storage Type
*Use Storage Accounts*
 
Deployments Storage Account Name  
*see from ressource group/template output, start end end with an asterix*  
Default Security Group  
*AllowWebAndSSH*  

SSH Public Key  
*can't be blank*  

SSH Private Key  
*can't be blank*  

Azure Environment  
*Azure Stack*  

Tenant Management Resource Endpoint
```
(get-azurermcontext).Environment.ActiveDirectoryServiceEndpointResourceId
```

Domain  
*local.azurestack.external*  
Authentication  
*AzureAD*  
Azure Stack Endpoint Prefix
*management*  
Azure Stack CA Certificate
*lookup PEM file* 
```
.\admin\tools\export_root_cert.ps1
```
