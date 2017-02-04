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
 $parametersFilePath = "C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\Site1\af_vnet_azuredeploy.parameters1_Services.json"
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
#$Environment = 'AzureUSGovernment'
$Environment = 'AzureCloud'

$UserName='willst@microsoft.onmicrosoft.com'
$subID_CJIS=""
$SubName_CJIS='mac_slg_Managed_CJIS'
$subID_HBI="ce38c0ef-22f5-458d-b1f7-e3890e2471f2"
$SubName_HBI= 'MAC_SLG_Managed_HBI'
$subID_PreProd="a7d928df-fc97-4f02-adae-3d7cdeb7c8cb"
$subName_PreProd='MAC_SLG_Managed_PreProd'
$SubID_Prod="ec1cea2e-92aa-45a7-89b0-d9fc40df2beb"
$SubName_Prod='MAC_SLG_Managed_Prod'
$SubID_Services="730f26b5-ebf5-4518-999f-0b4eb0cdc8f9"
$SubName_Services="MAC_SLG_Managed_Services"
$SubID_Storage="6e5d19d2-a324-470a-b24f-57ac0d3221a1"
$SubName_Storage="MAC_SLG_Managed_Storage"
Login-AzureRmAccount -EnvironmentName $Environment;
$resourceGroupLocation = 'West Central US'
$location="westcentralus"


#>

Select-AzureRmSubscription -SubscriptionID $subID_Prod;
$ProdResourceGroupName="vnet_prod_w1"
#Create or check for existing resource group
$ProdResourceGroup = Get-AzureRmResourceGroup -Name $ProdResourceGroupName -ErrorAction SilentlyContinue
if(!$ProdResourceGroup)
{
    Write-Host "Resource group '$ProdResourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$Location) {
        $Location = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$ProdResourceGroupName' in location '$Location'";
    New-AzureRmResourceGroup -Name $ProdResourceGroupName -Location $Location
}
else{
    Write-Host "Using existing resource group '$ProdResourceGroupName'";
}

$prodParametersFilePath="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\Site1\af_vnet_azuredeploy.parameters1_Prod.json"
$prodTemplateFilePath="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\Site1\af_vnet_azuredeploy1_Prod.json"


# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourcegroupname -TemplateFile $prodTemplateFilePath -TemplateParameterFile $prodParametersFilePath;

New-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourceGroupName -Templatefile $prodTemplateFilePath -TemplateParameterfile $prodparametersFilePath;

