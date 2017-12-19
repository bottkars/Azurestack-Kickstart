$versions = (get-content .\admin\windowsupdate.json | ConvertFrom-Json)

foreach ($version in $versions){
    [string]$SKU_DATE = (get-date $Version.Date -Format "yyyyMMdd").ToString()
    [string]$sku_version = "$($Version.BUILD).$($SKU_DATE.ToString())"
    Write-host "`"$sku_version`","

}