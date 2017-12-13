# Azurestack-dsc

This repo is a Collection of scripts to run after AzureStack ASDK Installations
The Idea is to have base components/logins stored in a json template and consistent stored in Session Variables
The 2 Json Files to edit are admin.json and user.json, that have to be copied to the users Homedirectory

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

Start the post installation with
The Command will run itsself in elevated Mode
```Powershell
D:\azurestack-dsc\admin\01_post_deploy.ps1
```
This will:
    -disable updates
   - Install GitSCM, Chrome and Shortcuts for the Portals 
![image](https://user-images.githubusercontent.com/8255007/33950960-fb359682-e02d-11e7-87c7-4fc6d5f60f3c.png)



To set the initial Stack Konfiguration and install Powershell Modules run:
```Powershell
D:\azurestack-dsc\admin\03-initial_stack.ps1
```
The Command will run itsself in elevated Mode
![image]![image](https://user-images.githubusercontent.com/8255007/33956253-4c7f325e-e03e-11e7-8bc9-86c480d74424.png)



# Staring the customizations

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

 
