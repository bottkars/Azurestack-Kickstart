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
Service Principal created in AzureAD

Client Secret
*can't be blank*

Resource Group Name
can't be blank

BOSH Storage Account Name
*opsmanstorageaccount*
Cloud Storage Type

*Use Storage Accounts*
 
Deployments Storage Account Name
*see from ressource group, start end end with an asterix*
Default Security Group
*AllowWebAndSSH*
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
*local.azurestack.external*
Authentication
*AzureAD*
Azure Stack Endpoint Prefix

Azure Stack CA Certificate

```
.\admin\tools\export_root_cert.ps1
```
