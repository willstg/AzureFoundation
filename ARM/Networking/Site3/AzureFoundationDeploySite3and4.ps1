<#
 .SYNOPSIS
    Deploys the AzureFoundation templates for Site 3 and 4 of a four datacenter pattern.  Depending on the environment 
    you're deploying site 3, 

 .DESCRIPTION
    Deploys an Azure Resource Manager template assocazted to the first site in the AzureFoundation

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
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter txlues based on template.
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
 $templateFilePath = "C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy.parameters3.json",

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
$Environment = "AzureUSGovernment"
#$Environment = 'AzureCloud'
Login-AzureRmAccount -EnvironmentName $Environment;
$subID_HBI='97eba262-9086-4a3e-9770-dcfef6c3df30'
$SubName_HBI= 'slgmag_managed_HBI'
$subID_PreProd='a4b962d2-6b17-4c38-af02-010a6e774379'
$subName_PreProd='slgmag_managed_PreProd'
$SubID_Prod='4a0d1d83-f557-4065-8423-be499038298a'
$SubName_Prod='slgmag_managed_Production'
$SubID_Services='30457dd5-e56b-416b-9228-d48b37fe7caa'
$SubName_Services='slgmag_managed_Services'
$SubID_Storage='0223b7af-344f-42cd-bed2-5ebbc7d06d5d'
$SubName_Storage='slgmag_managed_Storage'
#First Site
$resourceGroupLocation1 = 'usgovtexas'
$location1='usgovtexas'
$servicesResourceGroupName1="rg_vnet_services_tx"
$prodResourceGroupName1="rg_vnet_prod_tx"
$preProdResourceGroupName1 ="rg_vnet_preprod_tx"
$hbiResourceGroupName1 ="rg_vnet_hbi_tx"
$storageResourceGroupName1 ="rg_vnet_storage_tx"
#Second Site
$resourceGroupLocation2 = 'usgovarizona'
$location2='usgovarizona'
$servicesResourceGroupName2="rg_vnet_services_az"
$prodResourceGroupName2="rg_vnet_prod_az"
$preProdResourceGroupName2 ="rg_vnet_preprod_az"
$hbiResourceGroupName2 ="rg_vnet_hbi_az"
$storageResourceGroupName2 ="rg_vnet_storage_az"

# select subscription
#Write-Host "Selecting subscription '$subscriptionId'";

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}


<#
*****************Services*******************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_Services;
$servicesResourceGroup1 = Get-AzureRmResourceGroup -Name $servicesResourceGroupName1 -ErrorAction SilentlyContinue

#Create or check for existing resource group
if(!$servicesResourceGroup1)
{
    Write-Host "Resource group '$servicesResourceGroupName1' does not exist. To create a new resource group, please enter a location.";
    if(!$Location1) {
        $Location1 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$servicesResourceGroupName1' in location '$Location1'";
    New-AzureRmResourceGroup -Name $servicesResourceGroupName1 -Location $Location1
}
else{
    Write-Host "Using existing resource group '$servicesResourceGroupName1'";
}
if(!$servicesResourceGroup2)
{
    Write-Host "Resource group '$servicesResourceGroupName2' does not exist. To create a new resource group, please enter a location.";
    if(!$Location2) {
        $Location2 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$servicesResourceGroupName2' in location '$Location2'";
    New-AzureRmResourceGroup -Name $servicesResourceGroupName2 -Location $Location2
}
else{
    Write-Host "Using existing resource group '$servicesResourceGroupName2'";
}
<#
This section is where we build the NSG for the VNET
#>

$servicesParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\networking\Site3\af_vnet_azuredeploy.parameters3_Services.json"
$servicesTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\networking\Site3\af_vnet_azuredeploy3_servicesB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourcegroupname1 -TemplateFile $servicesTemplateFilePath1 -TemplateParameterFile $servicesParametersFilePath1;

New-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourceGroupName1 -Templatefile $servicesTemplateFilePath1 -TemplateParameterfile $servicesParametersFilePath1;

$servicesParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy.parameters4_Services.json"
$servicesTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy4_servicesB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourcegroupname2 -TemplateFile $servicesTemplateFilePath2 -TemplateParameterFile $servicesParametersFilePath2;

New-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourceGroupName2 -Templatefile $servicesTemplateFilePath2 -TemplateParameterfile $servicesParametersFilePath2;

<#
**************************Production Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_Prod;
$prodResourceGroup1 = Get-AzureRmResourceGroup -Name $prodResourceGroupName1 -ErrorAction SilentlyContinue

if(!$prodResourceGroup1)
{
    Write-Host "Resource group '$prodResourceGroupName1' does not exist. To create a new resource group, please enter a location.";
    if(!$Location1) {
        $Location1 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$prodResourceGroupName1' in location '$Location1'";
    New-AzureRmResourceGroup -Name $prodResourceGroupName1 -Location $Location1
}
else{
    Write-Host "Using existing resource group '$prodResourceGroupName1'";
}
if(!$prodResourceGroup2)
{
    Write-Host "Resource group '$prodResourceGroupName2' does not exist. To create a new resource group, please enter a location.";
    if(!$Location2) {
        $Location2 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$prodResourceGroupName2' in location '$Location2'";
    New-AzureRmResourceGroup -Name $prodResourceGroupName2 -Location $Location2
}
else{
    Write-Host "Using existing resource group '$prodResourceGroupName2'";
}
<#
This section is where we build the NSG for the VNET
#>

$prodParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy.parameters3_prod.json"
$prodTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy3_prodB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourcegroupname1 -TemplateFile $prodTemplateFilePath1 -TemplateParameterFile $prodParametersFilePath1;
New-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourceGroupName1 -Templatefile $prodTemplateFilePath1 -TemplateParameterfile $prodParametersFilePath1;


$prodParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy.parameters4_prod.json"
$prodTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy4_prodB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourcegroupname2 -TemplateFile $prodTemplateFilePath2 -TemplateParameterFile $prodParametersFilePath2;

New-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourceGroupName2 -Templatefile $prodTemplateFilePath2 -TemplateParameterfile $prodParametersFilePath2;

<#
**************************PrepreProduction Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_preProd
$preProdResourceGroup1 = Get-AzureRmResourceGroup -Name $preProdResourceGroupName1 -ErrorAction SilentlyContinue

if(!$preProdResourceGroup1)
{
    Write-Host "Resource group '$preProdResourceGroupName1' does not exist. To create a new resource group, please enter a location.";
    if(!$Location1) {
        $Location1 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$preProdResourceGroupName1' in location '$Location1'";
    New-AzureRmResourceGroup -Name $preProdResourceGroupName1 -Location $Location1
}
else{
    Write-Host "Using existing resource group '$preProdResourceGroupName1'";
}
if(!$preProdResourceGroup2)
{
    Write-Host "Resource group '$preProdResourceGroupName2' does not exist. To create a new resource group, please enter a location.";
    if(!$Location2) {
        $Location2 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$preProdResourceGroupName2' in location '$Location2'";
    New-AzureRmResourceGroup -Name $preProdResourceGroupName2 -Location $Location2
}
else{
    Write-Host "Using existing resource group '$preProdResourceGroupName2'";
}
<#
This section is where we build the NSG for the VNET
#>

$preProdParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy.parameters3_preProd.json"
$preProdTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy3_preProdB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourcegroupname1 -TemplateFile $preProdTemplateFilePath1 -TemplateParameterFile $preProdParametersFilePath1;

New-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourceGroupName1 -Templatefile $preProdTemplateFilePath1 -TemplateParameterfile $preProdParametersFilePath1;

$preProdParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy.parameters4_preProd.json"
$preProdTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy4_preProdB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourcegroupname2 -TemplateFile $preProdTemplateFilePath2 -TemplateParameterFile $preProdParametersFilePath2;

New-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourceGroupName2 -Templatefile $preProdTemplateFilePath2 -TemplateParameterfile $preProdParametersFilePath2;

<#
**************************High Business Impact Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_HBI

$hbiResourceGroup1 = Get-AzureRmResourceGroup -Name $hbiResourceGroupName1 -ErrorAction SilentlyContinue
$hbiResourceGroup2 = Get-AzureRmResourceGroup -Name $hbiResourceGroupName2 -ErrorAction SilentlyContinue

if(!$hbiResourceGroup1)
{
    Write-Host "Resource group '$hbiResourceGroupName1' does not exist. To create a new resource group, please enter a location.";
    if(!$Location1) {
        $Location1 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$hbiResourceGroupName1' in location '$Location1'";
    New-AzureRmResourceGroup -Name $hbiResourceGroupName1 -Location $Location1
}
else{
    Write-Host "Using existing resource group '$hbiResourceGroupName1'";
}
if(!$hbiResourceGroup2)
{
    Write-Host "Resource group '$hbiResourceGroupName2' does not exist. To create a new resource group, please enter a location.";
    if(!$Location2) {
        $Location2 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$hbiResourceGroupName2' in location '$Location2'";
    New-AzureRmResourceGroup -Name $hbiResourceGroupName2 -Location $Location2
}
else{
    Write-Host "Using existing resource group '$hbiResourceGroupName2'";
}
<#
This section is where we build the NSG for the VNET
#>

$hbiParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy.parameters3_hbi.json"
$hbiTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy3_hbiB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourcegroupname1 -TemplateFile $hbiTemplateFilePath1 -TemplateParameterFile $hbiParametersFilePath1;
New-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourceGroupName1 -Templatefile $hbiTemplateFilePath1 -TemplateParameterfile $hbiParametersFilePath1;

$hbiParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy.parameters4_hbi.json"
$hbiTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy4_hbiB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourcegroupname2 -TemplateFile $hbiTemplateFilePath2 -TemplateParameterFile $hbiParametersFilePath2;
New-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourceGroupName2 -Templatefile $hbiTemplateFilePath2 -TemplateParameterfile $hbiParametersFilePath2;


<#
**************************Storage Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_Storage;
$storageResourceGroup1 = Get-AzureRmResourceGroup -Name $storageResourceGroupName1 -ErrorAction SilentlyContinue
$storageResourceGroup2 = Get-AzureRmResourceGroup -Name $storageResourceGroupName2 -ErrorAction SilentlyContinue

if(!$storageResourceGroup1)
{
    Write-Host "Resource group '$storageResourceGroupName1' does not exist. To create a new resource group, please enter a location.";
    if(!$Location1) {
        $Location1 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$storageResourceGroupName1' in location '$Location1'";
    New-AzureRmResourceGroup -Name $storageResourceGroupName1 -Location $Location1
}
else{
    Write-Host "Using existing resource group '$storageResourceGroupName1'";
}
if(!$storageResourceGroup2)
{
    Write-Host "Resource group '$storageResourceGroupName2' does not exist. To create a new resource group, please enter a location.";
    if(!$Location2) {
        $Location2 = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$storageResourceGroupName2' in location '$Location2'";
    New-AzureRmResourceGroup -Name $storageResourceGroupName2 -Location $Location2
}
else{
    Write-Host "Using existing resource group '$storageResourceGroupName2'";
}
$StorageParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy.parameters3_Storage.json"
$StorageTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site3\af_vnet_azuredeploy3_StorageB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $StorageResourcegroupname1 -TemplateFile $StorageTemplateFilePath1 -TemplateParameterFile $StorageParametersFilePath1;
New-AzureRmResourceGroupDeployment -ResourceGroupName $StorageResourceGroupName1 -Templatefile $StorageTemplateFilePath1 -TemplateParameterfile $StorageParametersFilePath1;

$storageParametersFilePath2 ="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy.parameters4_storage.json"
$storageTemplateFilePath2 ="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\Networking\Site4\af_vnet_azuredeploy4_storageB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $storageResourcegroupname2 -TemplateFile $storageTemplateFilePath2 -TemplateParameterFile $storageParametersFilePath2;
New-AzureRmResourceGroupDeployment -ResourceGroupName $storageResourceGroupName2 -Templatefile $storageTemplateFilePath2 -TemplateParameterfile $storageParametersFilePath2;

