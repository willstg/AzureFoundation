<#
 .SYNOPSIS
    Deploys the AzureFoundation templates for Site 1 and 2 of a four datacenter pattern.  The metadata template that 
    created this template refers to these VNETs as VNET100 through VNET 204.

    VNET100:  Production Site 1
    VNET101:  HBI Site 1
    VNET102:  PreProd Site 1
    VNET103:  Storage Site 1
    VNET104:  Services Site 1

    VNET200:  Production Site 1
    VNET201:  HBI Site 1
    VNET202:  PreProd Site 1
    VNET203:  Storage Site 1
    VNET204:  Services Site 1

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
 $templateFilePath = "C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1.json",

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
#$Environment = "AzureUSGovernment"
$Environment = 'AzureCloud'
Login-AzureRmAccount -EnvironmentName $Environment;


#In these variables, use the Get-AzureRMSubscription command to list the subscriptions 
#Cut and Paste the values in the variables for the five standard subscriptions.
$UserName='willst@slg044o365.onmicrosoft.com'
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

#Update these fields for the datacenter pair to target the deployment at
#https://docs.microsoft.com/en-us/azure/best-practices-availability-paired-regions
$resourceGroupLocation = 'West Central US'
$location1="westcentralus"

$servicesResourceGroupName1="rg_vnet_services_w1"
$prodResourceGroupName1="rg_vnet_prod_w1"
$preProdResourceGroupName1 ="rg_vnet_preprod_w1"
$hbiResourceGroupName1 ="rg_vnet_hbi_w1"
$storageResourceGroupName1 ="rg_vnet_storage_w1"
#Second Site
$resourceGroupLocation2 = 'West US 2'
$location2='westus2'
$servicesResourceGroupName2="rg_vnet_services_w2"
$prodResourceGroupName2="rg_vnet_prod_w2"
$preProdResourceGroupName2 ="rg_vnet_preprod_w2"
$hbiResourceGroupName2 ="rg_vnet_hbi_w2"
$storageResourceGroupName2 ="rg_vnet_storage_w2"

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
$servicesResourceGroup2 = Get-AzureRmResourceGroup -Name $servicesResourceGroupName2 -ErrorAction SilentlyContinue

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
This section is where we build the NSG for the VNET afr locatedry where json files eecto ../ and run the powershell from di
#>
$deploymentName = "AzureFoundationSite1"
$servicesParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1_Services.json"
$servicesTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy1_servicesB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment  -ResourceGroupName $servicesResourcegroupname1 -TemplateFile $servicesTemplateFilePath1 -TemplateParameterFile $servicesParametersFilePath1;

New-AzureRmResourceGroupDeployment -name $deploymentName -ResourceGroupName $servicesResourceGroupName1 -Templatefile $servicesTemplateFilePath1 -TemplateParameterfile $servicesParametersFilePath1;
#Debug
#New-AzureRmResourceGroupDeployment -name $deploymentName -ResourceGroupName $servicesResourceGroupName1 -Templatefile $servicesTemplateFilePath1 -TemplateParameterfile $servicesParametersFilePath1 -DeploymentDebugLogLevel All;

$Operations = Get-AzureRmResourceGroupDeploymentOperation -DeploymentName $deploymentName -ResourceGroupName $servicesResourceGroupName1
foreach($Operation in $Operations){
Write-Host $operation.id
$Operation.properties.request | ConvertTo-Json -Depth 10
    Write-Host "Request:"
$Operation.properties.response | ConvertTo-Json -Depth 10
 Write-Host "Response:"}

$servicesParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy.parameters2_Services.json"
$servicesTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy2_servicesB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourcegroupname2 -TemplateFile $servicesTemplateFilePath2 -TemplateParameterFile $servicesParametersFilePath2;

New-AzureRmResourceGroupDeployment -ResourceGroupName $servicesResourceGroupName2 -Templatefile $servicesTemplateFilePath2 -TemplateParameterfile $servicesParametersFilePath2;

<#
**************************Production Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_Prod;
$prodResourceGroup1 = Get-AzureRmResourceGroup -Name $prodResourceGroupName1 -ErrorAction SilentlyContinue
$prodResourceGroup2 = Get-AzureRmResourceGroup -Name $prodResourceGroupName2 -ErrorAction SilentlyContinue

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

$prodParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1_prod.json"
$prodTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy1_prodB.json"

# Start the deployment

Test-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourcegroupname1 -TemplateFile $prodTemplateFilePath1 -TemplateParameterFile $prodParametersFilePath1;
New-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourceGroupName1 -Templatefile $prodTemplateFilePath1 -TemplateParameterfile $prodParametersFilePath1;


$prodParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy.parameters2_prod.json"
$prodTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy2_prodB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourcegroupname2 -TemplateFile $prodTemplateFilePath2 -TemplateParameterFile $prodParametersFilePath2;

New-AzureRmResourceGroupDeployment -ResourceGroupName $prodResourceGroupName2 -Templatefile $prodTemplateFilePath2 -TemplateParameterfile $prodParametersFilePath2;

<#
**************************PrepreProduction Subscription***************
#>

Select-AzureRmSubscription -SubscriptionID $SubID_preProd
$preProdResourceGroup1 = Get-AzureRmResourceGroup -Name $preProdResourceGroupName1 -ErrorAction SilentlyContinue
$preProdResourceGroup2 = Get-AzureRmResourceGroup -Name $preProdResourceGroupName2 -ErrorAction SilentlyContinue

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

$preProdParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1_preProd.json"
$preProdTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy1_preProdB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourcegroupname1 -TemplateFile $preProdTemplateFilePath1 -TemplateParameterFile $preProdParametersFilePath1;

New-AzureRmResourceGroupDeployment -ResourceGroupName $preProdResourceGroupName1 -Templatefile $preProdTemplateFilePath1 -TemplateParameterfile $preProdParametersFilePath1;

$preProdParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy.parameters2_preProd.json"
$preProdTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy2_preProdB.json"

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

$hbiParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1_hbi.json"
$hbiTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy1_hbiB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourcegroupname1 -TemplateFile $hbiTemplateFilePath1 -TemplateParameterFile $hbiParametersFilePath1;

New-AzureRmResourceGroupDeployment -ResourceGroupName $hbiResourceGroupName1 -Templatefile $hbiTemplateFilePath1 -TemplateParameterfile $hbiParametersFilePath1;

$hbiParametersFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy.parameters2_hbi.json"
$hbiTemplateFilePath2="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy2_hbiB.json"

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
$StorageParametersFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy.parameters1_Storage.json"
$StorageTemplateFilePath1="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site1\af_vnet_azuredeploy1_StorageB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $StorageResourcegroupname1 -TemplateFile $StorageTemplateFilePath1 -TemplateParameterFile $StorageParametersFilePath1;

$storageParametersFilePath2 ="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy.parameters2_storage.json"
$storageTemplateFilePath2 ="C:\Users\WILLS\Source\Repos\AzureFoundation\ARM\VNET\site2\af_vnet_azuredeploy2_storageB.json"

# Start the deployment
Test-AzureRmResourceGroupDeployment -ResourceGroupName $storageResourcegroupname2 -TemplateFile $storageTemplateFilePath2 -TemplateParameterFile $storageParametersFilePath2;
New-AzureRmResourceGroupDeployment -ResourceGroupName $StorageResourceGroupName1 -Templatefile $StorageTemplateFilePath1 -TemplateParameterfile $StorageParametersFilePath1;

New-AzureRmResourceGroupDeployment -ResourceGroupName $storageResourceGroupName2 -Templatefile $storageTemplateFilePath2 -TemplateParameterfile $storageParametersFilePath2;

