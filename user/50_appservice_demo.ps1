param(
$App_Name = "myApp")

$Subscription_ID = (Get-AzureRmSubscription).Id

$Template_uri = "https://raw.githubusercontent.com/bottkars/AzureStack-QuickStart-Templates/patch-3/201-webapp-and-serviceplan/azuredeploy.json"

$Location = "local"
$RG_NAME ="$App_Name"
$Hosting_plan_name = "$($App_Name)_plan"

$parameters = @{}
$parameters.Add("appname",$App_Name)
$parameters.Add("hostingPlanName",$Hosting_plan_name)
$parameters.Add("hostingEnvironment","")
$parameters.Add("subscriptionId",$Subscription_ID)
$parameters.Add("location",$Location)
$parameters.Add("workerSize","0")
$parameters.Add("skuCode","D1")
$parameters.Add("sku","shared")
$parameters.Add("serverFarmResourceGroup",$App_Name)
$Provider = "Microsoft.Web"
if ((Get-AzureRmResourceProvider -ProviderNamespace $Provider).RegistrationState[-1] -ne "Registered")
    {
    Write-Host -NoNewline "Registering AzureRM Resource Provider $Provider"
    Register-AzureRmResourceProvider -ProviderNamespace $Provider
    do {$RegistrationState = (Get-AzureRmResourceProvider -ProviderNamespace $Provider).RegistrationState  
    write-host -NoNewline .
    sleep 5}
    until ($RegistrationState -eq "Registered")
    }
Write-Host
New-AzureRmResourceGroup -ResourceGroupName $RG_NAME -Location $Location
New-AzureRmResourceGroupDeployment -Name "$($App_Name)_Deployment" `
    -TemplateUri $Template_uri -ResourceGroupName $RG_NAME `
    -TemplateParameterObject $parameters -Verbose