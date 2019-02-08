# OSX Gotchas
this is a collection of my tweaks to run azure-cli on OSX with azurestack /azurestack asdk
1. Certificates fo azure-cli
Import the certificate in the correct store. 

* Set Environment for REQUESTS_CA_BUNDLE with python

    ```azurecli
    export REQUESTS_CA_BUNDLE=/Library/Python/2.7/site-packages/certifi/cacert.pem
    ```

* Set Environment for REQUESTS_CA_BUNDLE with python3

    * install certifi
    ```zsh
    pip3 install certifi
    ```

    * get cert store
    ```zsh
    python3 -c "import certifi; print(certifi.where())"
    ```
    * append your root ca to cert store  

    ```zsh
    cat Documents/root.pem >> /usr/local/lib/python3.7/site-packages/certifi/cacert.pem
    ```

    * export REQUESTS_CA_BUNDLE

    ```zsh
    export REQUESTS_CA_BUNDLE=/usr/local/lib/python3.7/site-packages/certifi/cacert.pem
    ```

2. enabling bash completion with zsh/oh-my-zsh

```zsh
echo 'autoload -U +X bashcompinit && bashcompinit' >> ~/.zshrc
echo 'source /usr/local/etc/bash_completion.d/az' >> ~/.zshrc
```




3. Using the CLI

### Register an AzureStack user for multitenancy requires the correct endpoint 
[my pull request](https://github.com/MicrosoftDocs/azure-docs/pull/17808)

```azurecli
az cloud register \
  -n AzureStackUser \
  --endpoint-resource-manager "https://management.local.azurestack.external" \
  --suffix-storage-endpoint "local.azurestack.external" \
  --suffix-keyvault-dns ".vault.local.azurestack.external" \
  --endpoint-active-directory-resource-id="https://management.karstenbottemc.onmicrosoft.com/6a22cb35-aabc-40a2-bc24-d3a75a15d67e" \
  --endpoint-vm-image-alias-doc "https://raw.githubusercontent.com/bottkars/Azurestack-Kickstart/master/admin/tools/imagedoc.json" \
  --profile 2.40
```
### Update the Profile parameters
```azurecli
az cloud update \
  --profile 2.40
```


### register admin endpoint
```azurecli
az cloud register  -n AzureStackAdmin --endpoint-resource-manager \ "https://adminmanagement.local.azurestack.external" \
  --suffix-storage-endpoint "local.azurestack.external" \
  --suffix-keyvault-dns ".adminvault.local.azurestack.external"
```


5. ASDK VPN Connection

Connection to an ASDK is made from a vpn client.
For OSX, we need to create a new create a new vpn connection with the following settings ( translation to follow)

- Type: L2TP
- Name: <<your provided name>> 

![image](https://user-images.githubusercontent.com/8255007/47666096-01bb3b80-dba3-11e8-81d3-5498bb745400.png)  
    
- Configuration: Add
    - name: AzureStack
    - address: you azs ip
    - username: AzurestackAdmin

![image](https://user-images.githubusercontent.com/8255007/47666189-3202da00-dba3-11e8-9f22-3219e81499a6.png)  
- Authentication Settings
    - Password: Your AZS Admin Password
    - Key: Your AZD Admin Password

![image](https://user-images.githubusercontent.com/8255007/47666239-5494f300-dba3-11e8-811c-ef0ab3ab9cb7.png)  
- Advanced --> DNS  
    - add *.azurestack.external to search domains


In order to get connection to the Management and adminmanagement Endpoints as well as the Portals and Public IP´s,
we need to add some default routes to ppp0
therefore, edit /etc/ppp/ip-up :

```vi
#!/bin/sh

/sbin/route add -net 192.168.102.0/24 -interface $1
/sbin/route add -net 192.168.105.0/27 -interface $1
```
This will bring up the additional routes on ppp0   
you can manually update the routres then by  

```bash
sudo /etc/ppp/ip-up ppp0
```

## Clearing Browser
Safari stores login cookies and security settings.  
If your Web Browser has issues connecting to the Portal, you might want to clear the Security Settings.   
In Safari Settings, --> Data Protection, go to Website Settings   
![image](https://user-images.githubusercontent.com/8255007/47666309-84dc9180-dba3-11e8-9779-1242b47874a1.png)
Select Clear All Content  
![image](https://user-images.githubusercontent.com/8255007/47666330-945bda80-dba3-11e8-832e-4847a733ec1a.png)  

