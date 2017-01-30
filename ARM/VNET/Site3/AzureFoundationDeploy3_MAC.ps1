<#
 .SYNOPSIS
    Deploys the AzureFoundation templates for Site 1 of a four datacenter pattern.

 .DESCRIPTION
    Deploys an Azure Resource Manager template associated to the first site in the AzureFoundation

 .PARAMETERs 
    subscriptionId_prod
    The subscription ids where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $subscriptionId,

 [Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName,

 [string]
 $location,

 [Parameter(Mandatory=$True)]
 [string]
 $deploymentName,

 [string]
 $templateFilePath = "C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\Site1\af_vnet_azuredeploy.parameters1.json",

 [string]
 $parametersFilePath = "azuredeployparameters.json"
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount -EnvironmentName $Environment;
$resourceGroupLocation = 'South Central US'
$location="South Central US"

# select subscription
#Write-Host "Selecting subscription '$subscriptionId'";
$subscriptionId=$SubID_Services
Select-AzureRmSubscription -SubscriptionID $subscriptionId;
$resourceGroupName="vdc_vnet_tx_temp"
# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$Location) {
        $Location = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$Location'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}
<#
This section is where we build the NSG for the VNET
#>
Site 1:  Texas MAC
$localparametersFilePath="C:\Users\WILLS\Source\Repos\VDC\VDC_VNET_TX\azuredeploy.parameters1.json"
$localtemplateFilePath="C:\Users\WILLS\Source\Repos\VDC\VDC_VNET_TX\azuredeploy1.json"
#Site 2:  Illiniois MAC

#Site 3:  Virginia MAG
#Site 4:  Iowa MAG



# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourcegroupname -TemplateFile $localtemplateFilePath -TemplateParameterFile $localParametersFilePath;

New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Templatefile $localtemplateFilePath -TemplateParameterfile $localparametersFilePath;

