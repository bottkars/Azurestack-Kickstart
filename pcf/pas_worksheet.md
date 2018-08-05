# PAS Deployment Worksheet

![image](https://user-images.githubusercontent.com/8255007/43384579-bf204240-93de-11e8-9130-1751cab3c152.png)  


## Upload TILE to OPS Manager Director

## Configuration

### On networks TAB  
select MANAGEMENT  
![image](https://user-images.githubusercontent.com/8255007/43381265-6f119196-93d4-11e8-8290-4899c8db41ea.png) 

### On Domains  Tab  
enter you DNS Zone Information  
![image](https://user-images.githubusercontent.com/8255007/43381467-0dd1a78a-93d5-11e8-876f-98fb954422c4.png)  

### On Networking Tab  
create an SSL Certificate for the following domains:  
*note, the below domains are for use with an ASDK, on an integrated system replace _pcf.local.azurestack.external_ with your _pcfzone.region.azurestackdomain_*
```
*.pcf.local.azurestack.external,
*.system.pcf.local.azurestack.external,
*.apps.pcf.local.azurestack.external,
*.uaa.system.pcf.local.azurestack.external,
*.login.system.pcf.local.azurestack.external
```
![image](https://user-images.githubusercontent.com/8255007/43381969-a5846e40-93d6-11e8-9c48-ad4db23e5b69.png)

disable SSL Verification  

![image](https://user-images.githubusercontent.com/8255007/43381624-83408bc6-93d5-11e8-972c-78afe0030b5f.png)

disable HAproxy SSL Forwarding  
![image](https://user-images.githubusercontent.com/8255007/43382177-42a80876-93d7-11e8-97d0-d3e6cf03c933.png)  

### On Application Security Groups
Confirm with X
![image](https://user-images.githubusercontent.com/8255007/43382226-692b11c8-93d7-11e8-884a-a409eb8169a7.png)

### On UAA Tab

create an SSL Certificate for the following domains:  
```
*.login.system.pcf.local.azurestack.external
```
enter Passphrase

### On CredHUB TAB  
create a Primary Encryption KERY
*Passphrase must not be shorter then 20 chars*

### On Internal MySQL Tab  
enter a Valid E-Mail Address

### On Ressources TAB

For ASDK, Scale ressources down to 2 where Possible

Assign the Loadbalancers to:
mysql-lb to MYSql Proxy  
pcf-lb to Router  
diegossh-lb to Diego Cell  
![image](https://user-images.githubusercontent.com/8255007/43383270-ce943bfe-93da-11e8-8b18-d89899fa0e04.png)

