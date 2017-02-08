
Select-AzureRmSubscription -SubscriptionID $SubID_Services;
$KeyVault=Get-AzureRmKeyVault
$location="westcentralus"
$keyVaultResourceGroupName = "rg_SLGaKeyVault"
$keyVaultResourceGroup = Get-AzureRmResourceGroup -Name $keyvaultResourceGroupName -ErrorAction SilentlyContinue

#Create or check for existing resource group
if(!$keyVaultResourceGroup)
{
    Write-Host "Resource group '$keyVaultResourceGroup ' does not exist. To create a new resource group, please enter a location.";
    if(!$Location) {
        $Location = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$keyVaultResourceGroup ' in location '$Location'";
    New-AzureRmResourceGroup -Name $keyvaultResourceGroupName -Location $Location
}
else{
    Write-Host "Using existing resource group '$keyVaultResourceGroup '";
}

$resourceProviders = @("microsoft.compute","microsoft.network");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}


$keyvaultParametersFilePath="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\KeyVault\AzureDeploy.KeyVault.parameters.json"
$keyvaultTemplateFilePath="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\KeyVault\AzureDeploy.KeyVault.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $keyvaultResourcegroupName -TemplateFile $keyvaultTemplateFilePath -TemplateParameterFile $keyvaultParametersFilePath;
New-AzureRmResourceGroupDeployment -ResourceGroupName $keyvaultResourceGroupName -Templatefile $keyvaultTemplateFilePath -TemplateParameterfile $keyvaultParametersFilePath;
