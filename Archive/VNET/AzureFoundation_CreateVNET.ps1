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
    AzureFoundation_CreateVNET.ps1 
 Description:
    The prescriptive pattern of the AzureFoundation includes preconfigured XML documents.
    The implimentation of the network VNETS and Subnets are coordinated with the 
    EA_AzureFoundation_Working spreadsheet that has step by step instructions in the Notes
    worksheet.

    Start:  There are no VNETs defined for the five default subscriptions.  There is one VNET
    Config for each Subscription.  This XML file is part of the pattern.  To prepare the XML file 
    determine what the RFC1918 address will be and what the "dept" name will be.  Open each of the 
    Five XML files and search for "10.130" and replace with "10.xxx" that matches the IP space you 
    have determined for the agency.  Save these files to a working directory that matches the 
    variable below.  Next make a copy of this script and save it in the working directory.  (Opportunity,
    to make a branch off of the source and use source control for the new agency).  Search for "mac_slg" and 
    replace with "mag_*" where * is the Agency name.  THe variable names will line up with the XML 
    Documents now.

    End:  The VNETs for the five subscriptions are configured with VPN connections between two
    datacenters and the Services subscription.
 VERSION: 
    0.1
Author:  willstg@msn.com
------------------------------------------------------------------------------ 
#>

function SetLocalNetworkSiteGateways { 
  <# 
  .SYNOPSIS 
 This function will accept an XML file that defines a WIndows Azure Classic Network and set the gateway address
 In the file.  It is up to the calling funciton to save the file.
  .DESCRIPTION 
 The AzureFoundation pattern is a prescription of five subscriptions that interconnect with each other.  The 
 logic to seperate environment into five subscriptions is justified by security and lifecycle management.  Tier0
 data, Identity data, is hosted in Services and all of the subscriptions will have access to their Services
 Subscription.  The Subscriptions will have a regional pair of data centers that will also have a gateway to talk 
 with each other.
  .EXAMPLE 
  Give an example of how to use it 
  .EXAMPLE 
  Give another example of how to use it 
  .PARAMETER VNETXML
  THe VNETXML file will be passed and this function will update variables in the file. 
  .PARAMETER logname 
  The name of a file to write failed computer names to. Defaults to errors.txt. 
  #> 
    
    param( [Parameter(Mandatory=$true)] [System.String] $XMLPath, [System.String] $LogName)


  
    write-verbose "Beginning process loop" 
#Test 
#With this method we make XML from the file past in second parameter.
#    $VNETXML = Get-Content $XMLPath

#This method concerts the Object to XML
#$XMLPath=$XML_Services
[XML]$VNETXML = Get-Content($XMLPath)
Write-Output $XMLPath + $LogPath

    foreach($LNS in $VNetXML.NetworkConfiguration.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite)
    {
               if($LNS.Name -eq $VNETName_Services1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Services1.VIPAddress
            }
        
        If($LNS.name -eq $VNETName_Services2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Services2.VIPAddress
            }
        
        If($LNS.name -eq $VNETName_Storage1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Storage1.VIPAddress
            }
       
        If($LNS.name -eq $VNETName_Storage2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Storage2.VIPAddress
            }
           
        If($LNS.name -eq $VNETName_PreProd1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_PreProd1.VIPAddress
            }
           
        If($LNS.name -eq $VNETName_PreProd2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_PreProd2.VIPAddress
            }
         
        If($LNS.name -eq $VNETName_Prod1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Prod1.VIPAddress
            }        
          
        If($LNS.name -eq $VNETName_Prod2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Prod2.VIPAddress
            }
          
        If($LNS.name -eq $VNETName_CJIS1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_CJIS1.VIPAddress
            }
            
        If($LNS.name -eq $VNETName_CJIS2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_CJIS2.VIPAddress
            }
      } 

$VNETXML.save($XMLPath)
   } 


function connectLocalNetworks {
    param([Parameter(Mandatory=$true)] [System.String] $XMLPath, [Parameter(Mandatory=$true)][System.String] $VNETName, [System.String] $LogName)
#Test
#$XMLPath = $XML_Storage
#$VNETName = $VNETName_services2

[XML]$VNETXML = Get-Content($XMLPath)
if ($SharedKey -eq $null){
$sharekey = Read-Host "Enter the Shared Key for the Gateway"
}

Write-Output $XMLPath + $LogPath

    foreach($LNS in $VNetXML.NetworkConfiguration.VirtualNetworkConfiguration.LocalNetworkSites.LocalNetworkSite)
    {
    write-output $LNS.name + $VNETName
    Set-AzureVNetGateway -Connect -LocalNetworkSiteName $LNS.name -VNetName $VNETName -ErrorAction SilentlyContinue
    Set-AzureVNETGatewayKey -VNetName $VNETName -LocalNetworkSiteName $LNS.name -SharedKey $SharedKey -ErrorAction SilentlyContinue
   
   #Pause
    }
     }
#Set the Network Configuration file

$WorkingPath='c:\temp\slg\'
$Path="c:\temp\slg\"
$date = Get-Date
$filedate = $date.ToString("yyyyMMdd")
#What kind of a gateway do you want?  Default, Standard, HighPerformance are the choices
$GatewaySKU = "Default"
#Should the VPN Connections be established?
$Connect = 1

#Services Subscription


$file_services=$Path+"AzureFoundation_Services_Working.xml"
$XML_Services = $WorkingPath+"AzureFoundation_Services_Working.xml"
#The following variables come out of the XML file for the VNET name.
$VNETName_Services1= "mac_slg_managed_services_VA"
$VNETName_Services2= "mac_slg_managed_services_IA"

#Backup the current file incase something goes wrong and you use the wrong path
$ErrorLog_Services = $WorkingPath + "ErrorLog_Servivces"+$filedate+".txt"
$Backup_Services=$WorkingPath+"AzureFoundation_services_Working.xml.backup"+$fileDate
$XML_Services=$WorkingPath+"AzureFoundation_services_Working.xml"
#
#Storage Subscription
#

$ErrorLog_Storage = $WorkingPath + "ErrorLog_Storage"+$filedate+".txt"
$Backup_Storage=$WorkingPath+"AzureFoundation_Storage_Working.xml.backup"+$fileDate
$File_storage=$Path+"AzureFoundation_storage_Working.xml"
$XML_Storage = $WorkingPath+"AzureFoundation_Storage_Working.xml"
$VNETName_Storage1= "mac_slg_managed_storage_VA"
$VNETName_Storage2= "mac_slg_managed_storage_IA"
#PreProd Subscription
#

$ErrorLog_PreProd = $WorkingPath + "ErrorLog_PreProd"+$filedate+".txt"
$File_PreProd=$Path+"AzureFoundation_PreProd_Working.xml"
$XML_PreProd = $WorkingPath+"AzureFoundation_PreProd_Working.xml"
$VNETName_PreProd1= "mac_slg_managed_PreProd_VA"
$VNETName_PreProd2= "mac_slg_managed_PreProd_IA"
#Prod Subscription
#

$ErrorLog_Prod = $WorkingPath + "ErrorLog_Prod"+$filedate+".txt"
$File_Prod=$Path+"AzureFoundation_Prod_Working.xml"
$XML_Prod = $WorkingPath+"AzureFoundation_Prod_Working.xml"
$VNETName_Prod1= "mac_slg_managed_Prod_VA"
$VNETName_Prod2= "mac_slg_managed_Prod_IA"
$Backup_Prod=$WorkingPath+"AzureFoundation_Prod_Working.xml.backup"+$fileDate
#CJIS Subscription
#

$ErrorLog_CJIS = $WorkingPath + "ErrorLog_CJIS"+$filedate+".txt"
$File_CJIS=$Path+"AzureFoundation_CJIS_Working.xml"
$XML_CJIS = $WorkingPath+"AzureFoundation_CJIS_Working.xml"
$VNETName_CJIS1= "mac_slg_managed_CJIS_VA"
$VNETName_CJIS2= "mac_slg_managed_CJIS_IA"
$Backup_CJIS=$WorkingPath+"AzureFoundation_CJIS_Working.xml.backup"+$fileDate

#
#Services Subscription
#
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
$BackupVnet_Services=Get-AzureVNetConfig -ExportToFile $Backup_Services
#Are Gateways aleady defined?  One file is used for both sites.
If(-not ($Gateway_Services1=Get-AzureVNETGateway -VNETName $VNETName_Services1 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_Services
$Gateway_Services1=Get-AzureVNETGateway -VNETName $VNETName_Services1
}

#Now we check the first Gateway to see if it is provisioned.
if($Gateway_Services1.State -eq "NotProvisioned")
{
#Now we will "Import" the XML like we would in the Management GUI
Set-AzureVNetConfig -ConfigurationPath $file_Services
New-AzureVNetGateway -VNetName $VNETName_Services1 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}

#Now we check the second Gateway to see if it is provisioned.
$Gateway_Services2=Get-AzureVNETGateway -VNETName $VNETName_Services2 -ErrorAction SilentlyContinue
if($Gateway_Services2.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_Services
New-AzureVNetGateway -VNetName $VNETName_Services2 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
$VPNGW_Services1 = Get-AzureVNetGateway -VNetName $VnetName_Services1
$VPNGW_Services2 = Get-AzureVNetGateway -VnetName $VNETName_Services2
#
#Storage Subscription
#
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
#Backup the current file incase something goes wrong and you use the wrong path
$Vnet_Storage=Get-AzureVNetConfig -ExportToFile $Backup_Storage
#Is there a VNET Defined?  If this errors out there isn't.
If(-not ($Gateway_Storage1=Get-AzureVNETGateway -VNETName $VNETName_Storage1 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_Storage
$Gateway_Storage1=Get-AzureVNETGateway -VNETName $VNETName_Storage1 -ErrorAction SilentlyContinue
}
#Are Gateways aleady defined?
if($Gateway_Storage1.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_Storage
New-AzureVNetGateway -VNetName $VNETName_Storage1 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
If(-not ($Gateway_Storage2=Get-AzureVNETGateway -VNETName $VNETName_Storage2 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_Storage
}
if($Gateway_Storage2.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_Storage
New-AzureVNetGateway -VNetName $VNETName_Storage2 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
$VPNGW_Storage1 = Get-AzureVNetGateway -VNetName $VnetName_Storage1
$VPNGW_Storage2 = Get-AzureVNetGateway -VnetName $VNETName_Storage2
#
#PreProd Subscription
#

Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current

#Backup the current file in case something goes wrong and you use the wrong path
$Backup_PreProd=$WorkingPath+"AzureFoundation_PreProd_Working.xml.backup"+$fileDate
$Vnet_PreProd=Get-AzureVNetConfig -ExportToFile $Backup_PreProd
#Are Gateways aleady defined?
If(-not ($Gateway_PreProd1=Get-AzureVNETGateway -VNETName $VNETName_PreProd1 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_PreProd
$Gateway_PreProd1=Get-AzureVNETGateway -VNETName $VNETName_PreProd1 -ErrorAction SilentlyContinue
}
if($Gateway_PreProd1.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_PreProd
New-AzureVNetGateway -VNetName $VNETName_PreProd1 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
If(-not ($Gateway_PreProd2=Get-AzureVNETGateway -VNETName $VNETName_PreProd2 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_PreProd
}
if($Gateway_PreProd2.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_PreProd
New-AzureVNetGateway -VNetName $VNETName_PreProd2 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
$VPNGW_PreProd1 = Get-AzureVNetGateway -VNetName $VnetName_PreProd1
$VPNGW_PreProd2 = Get-AzureVNetGateway -VnetName $VNETName_PreProd2
#
#Prod Subscription
#

Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
$Vnet_Prod=Get-AzureVNetConfig -ExportToFile $Backup_Prod
#Are Gateways aleady defined?
If(-not ($Gateway_Prod1=Get-AzureVNETGateway -VNETName $VNETName_Prod1 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_Prod
$Gateway_Prod1=Get-AzureVNETGateway -VNETName $VNETName_Prod1 -ErrorAction SilentlyContinue
}
if($Gateway_Prod1.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_Prod
New-AzureVNetGateway -VNetName $VNETName_Prod1 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
If(-not ($Gateway_Prod2=Get-AzureVNETGateway -VNETName $VNETName_Prod2 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_Prod
}
if($Gateway_Prod2.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_Prod
New-AzureVNetGateway -VNetName $VNETName_Prod2 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
$VPNGW_Prod1 = Get-AzureVNetGateway -VNetName $VnetName_Prod1
$VPNGW_Prod2 = Get-AzureVNetGateway -VnetName $VNETName_Prod2
#
#CJIS Subscription
#
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current

#Backup the current file incase something goes wrong and you use the wrong path
$Vnet_CJIS=Get-AzureVNetConfig -ExportToFile $Backup_CJIS
#Are Gateways aleady defined?
If(-not ($Gateway_CJIS1=Get-AzureVNETGateway -VNETName $VNETName_CJIS1 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_CJIS
$Gateway_CJIS1=Get-AzureVNETGateway -VNETName $VNETName_CJIS1 -ErrorAction SilentlyContinue
}
if($Gateway_CJIS1.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_CJIS
New-AzureVNetGateway -VNetName $VNETName_CJIS1 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
If(-not ($Gateway_CJIS2=Get-AzureVNETGateway -VNETName $VNETName_CJIS2 -ErrorAction SilentlyContinue))
{
Set-AzureVNetConfig -ConfigurationPath $file_CJIS
}
if($Gateway_CJIS2.State -eq "NotProvisioned")
{
Set-AzureVNetConfig -ConfigurationPath $file_CJIS
New-AzureVNetGateway -VNetName $VNETName_CJIS2 -GatewayType "DynamicRouting" -GatewaySKU $GatewaySKU
}
$VPNGW_CJIS1 = Get-AzureVNetGateway -VNetName $VnetName_CJIS1
$VPNGW_CJIS2 = Get-AzureVNetGateway -VnetName $VNETName_CJIS2
#Now everything should be set for the Networks, and we need to update the other networks so they 
#Can have a VPN connection back to each other.  This wasn't possible until now because we
#Didn't have the gateways assisgned.

#
#Services
#
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_Services
SetLocalNetworkSiteGateways $XML_Services $ErrorLog_Services
Set-AzureVNetConfig -ConfigurationPath $XML_Services
#
#Storage
#
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_Storage
SetLocalNetworkSiteGateways $XML_Storage $ErrorLog_Storage 
Set-AzureVNetConfig -ConfigurationPath $XML_Storage
#
#Prod
#
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_Prod
SetLocalNetworkSiteGateways $XML_Prod $ErrorLog_Prod 
Set-AzureVNetConfig -ConfigurationPath $XML_Prod
#
#PreProd
#
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_PreProd
SetLocalNetworkSiteGateways $XML_PreProd $ErrorLog_PreProd
Set-AzureVNetConfig -ConfigurationPath $XML_PreProd
#
#CJIS
#
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_CJIS
SetLocalNetworkSiteGateways $XML_CJIS $ErrorLog_CJIS
Set-AzureVNetConfig -ConfigurationPath $XML_CJIS

#Now all of the local network gateways are set correctly and we need to make the decision to connect 
#The VPN gateways between the Subscription's VPN and the Local Networks it is expected to Connecto to
#

if($Connect -eq 1){
#
#Services
#
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Get-AzureVNetConfig -ExportToFile $XML_Services
connectLocalNetworks $XML_Services $VNETName_Services1 $ErrorLog_Services
connectLocalNetworks $XML_Services $VNETName_Services2 $ErrorLog_Services
#
#Storage
#
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_Storage
connectLocalNetworks $XML_Storage $VNETName_Storage1 $ErrorLog_Storage
connectLocalNetworks $XML_Storage $VNETName_Storage2 $ErrorLog_Storage
#
#Prod
#
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
Get-AzureVNetConfig -ExportToFile $XML_Prod
connectLocalNetworks $XML_Prod $VNETName_Prod1 $ErrorLog_Prod
connectLocalNetworks $XML_Prod $VNETName_Prod2 $ErrorLog_Prod
#
#PreProd
#
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_PreProd
connectLocalNetworks $XML_PreProd $VNETName_PreProd1 $ErrorLog_PreProd
connectLocalNetworks $XML_PreProd $VNETName_PreProd2 $ErrorLog_PreProd
#
#CJIS
#
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
#Set the XML File for the VNET now that we have the Gateway configured
Get-AzureVNetConfig -ExportToFile $XML_CJIS
connectLocalNetworks $XML_CJIS $VNETName_CJIS1 $ErrorLog_CJIS
connectLocalNetworks $XML_CJIS $VNETName_CJIS2 $ErrorLog_CJIS
}