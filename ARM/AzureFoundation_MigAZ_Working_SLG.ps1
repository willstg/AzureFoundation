<#------------------------------------------------------------------------------ 
 
 Copyright © 2016 Microsoft Corporation.  All rights reserved. 
 
 THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT 
 WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
 LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS 
 FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR  
 RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER. 
 
------------------------------------------------------------------------------ 
 
 PowerShell Source Code 
 
 NAME: 
    AzureFoundation_MigAZ_Working.ps1 
 Description:
    The prescriptive pattern of the AzureFoundation includes preconfigured JSON documents.
    The implimentation of the AzureFoundation are coordinated with the 
    EA_AzureFoundation_Working spreadsheet that has step by step instructions in the Notes
    worksheet.

    Start:  The AzureFoundation_InitiatePowerShell_Working.ps1 has been executed to set up the enviornment
    The MigAz program is a community supported program to help with the migration of resources
    ASM to ARM.  https://github.com/Azure/classic-iaas-resourcemanager-migration/tree/master/migaz.  
    Create a directory structure for an Azure Enrollment starting with the Subscription Names, Locations (2), 
    The ResourceGroup names, and go subscription by subscription in the tool to migrate the resources.  
    The resulting directories will each contain and export.json deployment that this powershell will use.

    End:  All of the resources that are part of the Enrollment, subscription by subscription will be migrated

 VERSION: 
    0.1
Author:  willstg@msn.com
------------------------------------------------------------------------------ 
#>

function MigAZ { 
  <# 
  .SYNOPSIS 
 This function will accept the variables requird to deploy the export of the MigAZ program.
  .DESCRIPTION 
 The AzureFoundation pattern is a prescription of five subscriptions that interconnect with each other.  The 
 logic to seperate environment into five subscriptions is justified by security and lifecycle management.  Tier0
 data, Identity data, is hosted in Services and all of the subscriptions will have access to their Services
 Subscription.  The Subscriptions will have a regional pair of data centers that will also have a gateway to talk 
 with each other.  Each of the 
  .EXAMPLE 
  Give an example of how to use it 
  .EXAMPLE 
  MigAZ ($SubID_Services, $RGName_Services_VNET_S1, $Location_S1, $Directory_Services_VNET_S1)
  .PARAMETER RGName
  The RGName is the ResourceGroup that the deployment will use.
  .PARAMETER Location
  The name of the Azure Location that the resource will be deployed in

  #> 
    
    param( 
        [Parameter(Mandatory=$true)] [System.String] $SubID,
        [Parameter(Mandatory=$true)] [System.String] $RGName,
        [Parameter(Mandatory=$true)] [System.String] $Location, 
        [Parameter(Mandatory=$true)] [System.String] $Directory, 
         [System.String] $LogName)

#Start the Function
<#TEST Area
$Subid=$SubID_Services
$RGName=$RGName_Services_VNET_S1
$Location=$Location_Services_VNet_S1 
$Directory=$MigAZDir_Services_VNET_S1
#>
$JSONTemp = "$Directory"+"export.json"
$JSONCopy = "$Directory"+"copyblobdetails.json"
$BlobCopyProg = "$MigAzDirectory"+"BlobCopy.ps1"
Select-AzureRmSubscription -SubscriptionId $SubID
New-AzureRmResourceGroup -Name $RGName -Location $Location
New-AzureRmResourceGroupDeployment -TemplateFile $JSONTemp -ResourceGroupName $RGName 

#is there anything to copy? 
# Load blob copy details file (ex: copyblobdetails.json)
$copyblobdetails = Get-Content -Path $JSONCopy -Raw | ConvertFrom-Json
if($copyblobdetails.(0) -eq $null)
{

Write-Host "Nothing to copy"
}
Else
{
powershell.exe $BlobCopyProg -ResourcegroupName $RGName -DetailsFilePath $JSONCopy -StartType StartBlobCopy
}
New-AzureRmResourceGroupDeployment -TemplateFile $JSONTemp -ResourceGroupName $RGName
}

#Set up a bunch of the enviornemnts Meta-data.
$MigAzDirectory="C:\Users\WILLS\Downloads\migAz v1.4.9.0\"
$Location_S1 = "West Central US"
$Location_S2 = "West US 2"

#Services
$SubID_Services = $SubID_Services #This is set in the initiate script

#VNET Site 1
$RGName_Services_VNET_S1 = "vnet_services_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Services_VNET_S1 = 'C:\Temp\SLG\MigAz\Services\VNET\W1\'
#VNET Site 2
$RGName_Services_VNET_S2 = "vnet_services_w2"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Services_VNET_S2 = 'C:\Temp\SLG\MigAz\Services\VNET\W2\'
#VMs
$RGName_Services_VM_S1 = "DomainServices_services_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Services_VM_S1 = 'C:\Temp\SLG\MigAz\Services\VM\DomainServices\W1\'

#Storage
#VNET Site 1
$RGName_Storage_VNET_S1 = "vnet_Storage_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Storage_VNET_S1 = 'C:\Temp\SLG\MigAz\Storage\VNET\W1\'
#VNET Site 2
$RGName_Storage_VNET_S2 = "vnet_Storage_w2"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Storage_VNET_S2 = 'C:\Temp\SLG\MigAz\Storage\VNET\\W2'

#Prod
#VNET Site 1
$RGName_Prod_VNET_S1 = "vnet_Prod_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Prod_VNET_S1 = 'C:\Temp\SLG\MigAz\Prod\VNET\W1\'
#VNET Site 2
$RGName_Prod_VNET_S2 = "vnet_Prod_w2"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_Prod_VNET_S2 = 'C:\Temp\SLG\MigAz\Prod\VNET\W2\'

#PreProd
#VNET Site 1
$RGName_PreProd_VNET_S1 = "vnet_PreProd_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_PreProd_VNET_S1 = 'C:\Temp\SLG\MigAz\PreProd\VNET\W1\'
#VNET Site 2
$RGName_PreProd_VNET_S2 = "vnet_PreProd_w2"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_PreProd_VNET_S2 = 'C:\Temp\SLG\MigAz\PreProd\VNET\W2\'

#HBI
#VNET Site 1
$RGName_HBI_VNET_S1 = "vnet_HBI_w1"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_HBI_VNET_S1 = 'C:\Temp\SLG\MigAz\HBI\VNET\W1\'
#VNET Site 2
$RGName_HBI_VNET_S2 = "vnet_HBI_w2"  #Too bad this couldn't be gotten from the ASM config
$MigAZDir_HBI_VNET_S2 = 'C:\Temp\SLG\MigAz\HBI\VNET\W2\'


#RUN THE FUNCTION
MigAZ $SubID_Services $RGName_Services_VNET_S1 $Location_S1 $MigAZDir_Services_VNET_S1
MigAZ $SubID_Services $RGName_Services_VNET_S2 $Location_S2 $MigAZDir_Services_VNET_S2
MigAZ $SubID_Services $RGName_Services_VM_S1 $Location_S1 $MigAZDir_Services_VM_S1
