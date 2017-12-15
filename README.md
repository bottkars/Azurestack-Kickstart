# Azurestack-dsc

This repo is a Collection of scripts to run after AzureStack ASDK Installations 
The Idea is to have base components/logins stored in a json template and credentials stored in session variables.
The Consistent Approach allws you to "Bootstrap" your Shell session with the 99_bootstrap script(s)
The Bootstrap Scripts wll read the user / admin json files having envronment data stored from the Homedirectory


## example admin.json
```json
{
"Domain": "azurestack",
"VMPassword": "Password123!",
"TenantName": "contoso.onmicrosoft.com",
"subscriptionID": "8c21cadc-9e41-459e-bf4b-919aa2fad975",
"SubscriptionOwner": "Administrator@contoso.com.com", 
"PrivilegedEndpoint": "azs-ercs01.azurestack.local",
"serviceuser": "masadmin",
"cloudadmin": "cloudadmin",
"AZSTools_Location": "D:\\AzureStack-Tools",
"AzureRMProfile": "2017-03-09-profile",
"AzureSTackModuleVersion": "1.2.11",
"KeyvaultDnsSuffix": "adminvault.local.azurestack.external",
"ArmEndpoint": "https://adminmanagement.local.azurestack.external"
}
```
# Initail Post Installation
Start the post installation with
The Command will run itsself in elevated Mode
```Powershell
D:\azurestack-dsc\admin\01_post_deploy.ps1
```
This will:  
   - disable updates
   - Install GitSCM, Chrome and Shortcuts for the Portals 
![image](https://user-images.githubusercontent.com/8255007/33950960-fb359682-e02d-11e7-87c7-4fc6d5f60f3c.png)

## initial powershell modules config

To set the initial stack configuration and install Powershell Modules run:
```Powershell
D:\azurestack-dsc\admin\03-initial_stack.ps1
```
The Command will run itself in elevated Mode
![image]![image](https://user-images.githubusercontent.com/8255007/33956253-4c7f325e-e03e-11e7-8bc9-86c480d74424.png)

this task can be repeated at any time to update the AzureStack Powershell environment

## register the stack
```Powershell
D:\azurestack-dsc\admin\06-_register_tack.ps1
```


# Starting the customizations

we have to load now our admin environment
```Powershell
 D:\azurestack-dsc\admin\99_bootstrap.ps1
```  
![image](https://user-images.githubusercontent.com/8255007/33956638-7bd6c8d6-e03f-11e7-88b0-2293a6dd66bb.png)  
![image](https://user-images.githubusercontent.com/8255007/33956656-84f953b6-e03f-11e7-9018-27266d2a0ae6.png)  

## deploy Base Plans

```Powershell
D:\azurestack-dsc\admin\10_deploy_base_plans_and_quotas.ps1
```  
![image](https://user-images.githubusercontent.com/8255007/33957262-636e5f0a-e041-11e7-8c36-05a15bf939d8.png)  

## deploy Windows Marketplace Items from ISO
this needs to run in an Admin Session ...  
```Powershell
D:\azurestack-dsc\admin\99_bootstrap.ps1
D:\azurestack-dsc\admin\11_deploy_windows_marketplace_image.ps1
```
![image](https://user-images.githubusercontent.com/8255007/33983160-65a941c8-e0b3-11e7-8bb2-8200074af068.png)  

you can create Bulk Marketplace Images by using:
```Powershell
$KB = (get-content D:\azurestack-dsc\admin\windowsupdate.json | ConvertFrom-Json) |  Sort-Object  -Property Date | Select-Object KB | Where-Object KB -ne ""
$KB | D:\azurestack-dsc\admin\11_deploy_windows_marketplace_image.ps1 -ISOPath 'D:\updates\' -UpdatePath D:\updates\
```
this will batch create Marketplace Items for All Windows Server 2016 KB´s listed in the included windowsupdate.json   
the process is 
- checking if SKU and Version already in Marketplace
- eval the Steps
- download updates if not available
- clean up orphan vhd / cab files
the msu files remain in the $updatepath
![image](https://user-images.githubusercontent.com/8255007/34031744-164f69ca-e173-11e7-803a-d846d9571acd.png)

