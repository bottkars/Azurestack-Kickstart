# OSX Gotchas

## Certificates fo azure-cli
Import the certificate in the correct store. 


### Set Environment for REQUESTS_CA_BUNDLE with python2

/Library/Python/2.7/site-packages/certifi/cacert.pem

Set Environment for REQUESTS_CA_BUNDLE with python2.7
```azurecli
export REQUESTS_CA_BUNDLE=/Library/Python/2.7/site-packages/certifi/cacert.pem
```

### Set Environment for REQUESTS_CA_BUNDLE with python3

install certifi
```zsh
pip3 install certifi
```

run
```zsh
python3 -c "import certifi; print(certifi.where())"
```
append your root ca to cacert 

```
cat Documents/root.pem >> /usr/local/lib/python3.7/site-packages/certifi/cacert.pem
```

export REQUESTS_CA_BUNDLE

```zsh
export REQUESTS_CA_BUNDLE=/usr/local/lib/python3.7/site-packages/certifi/cacert.pem
```

## enabling bach copletion with zsh/oh-my-zsh






## Using the CLI

### Register an AzureStack user for multitenancy requires the correct endpoint 
[my pull request](https://github.com/MicrosoftDocs/azure-docs/pull/17808)

```azurecli
az cloud register \
  -n AzureStackUser \
  --endpoint-resource-manager "https://management.local.azurestack.external" \
  --suffix-storage-endpoint "local.azurestack.external" \
  --suffix-keyvault-dns ".vault.local.azurestack.external" \
  --endpoint-active-directory-resource-id="https://management.karstenbottemc.onmicrosoft.com/6a22cb35-aabc-40a2-bc24-d3a75a15d67e" \
  --endpoint-vm-image-alias-doc "https://images.blob.local.azurestack.external/images/imagedoc.json" \
  --profile 2018-03-01-hybrid
```
### Update the Profile parameters
```azurecli
az cloud update \
  --profile 2018-03-01-hybrid
```


### register admin endpoint
```azurecli
az cloud register  -n AzureStackAdmin --endpoint-resource-manager \ "https://adminmanagement.local.azurestack.external" \
  --suffix-storage-endpoint "local.azurestack.external" \
  --suffix-keyvault-dns ".adminvault.local.azurestack.external"
```