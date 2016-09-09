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
    AzureFoundation_CreateNSG.ps1 
 Description:
    The prescriptive pattern of the AzureFoundation includes preconfigured subnets.
    The implimentation of the network VNETS and Subnets are coordinated with the 
    EA_AzureFoundation_Working spreadsheet that has step by step instructions in the Notes
    worksheet.

    Start:  AzureFoundation VNETs and gateways have been created and we are ready to apply Network
    Security Groups (NSG).  The default rules will allow for standard traffic flows.

    End:  After the NSG script is applied all of the subnets will have default security.  The 
    application of these NSG will provide a layer of protection for any VM deployed in the subnet.


 VERSION: 
    0.1
Author:  willstg@msn.com
------------------------------------------------------------------------------ 
#>

#These are the VNET names and will be the validation that we have applied an NSG to every 
#Subnet.

$VNETName_Services1= "dept_managed_services_VA"
$VNETName_Services2= "dept_managed_services_IA"
$VNETName_Storage1= "dept_managed_storage_VA"
$VNETName_Storage2= "dept_managed_storage_IA"
$VNETName_PreProd1= "dept_managed_PreProd_VA"
$VNETName_PreProd2= "dept_managed_PreProd_IA"
$VNETName_CJIS1= "dept_managed_CJIS_VA"
$VNETName_CJIS2= "dept_managed_CJIS_IA"
$VNETName_Prod1= "dept_managed_Prod_VA"
$VNETName_Prod2= "dept_managed_Prod_IA"
$WorkingPath='c:\temp\CapGem\'
$Path="c:\temp\CapGem\"
$date = Get-Date
$filedate = $date.ToString("yyyyMMdd")



#We will set the current subscription and get the two VNETSites.
#  Each subnet will have a naming convention that will allow us to use the 
#  VNET number in the name to determine what rules will be applied 
#  To the subnet.

function NSGRules00 {
 <# 
  .SYNOPSIS 
 This function will put the default NSG rules for a subnet while associating those rules to the specific 
 Subnet.
  .DESCRIPTION 
 The AzureFoundation pattern is a prescription of five subscriptions that interconnect with each other.  The 
 logic to seperate environment into five subscriptions is justified by security and lifecycle management. Each 
 subnet has a naming convention that includes the subnet number:
    100:  Prod
    200:  CJIS or HBI data
    300:  TEST
    400:  DEV
    500:  Storage
    600:  Services Tier0 data
 The other numbers in the subnet numbers follow this convention.
    n00:  Tier0 Data
    n10:  Web
    n20:  App
    n30:  Database
    n50:  DMZ
    n60:  User Tier0 (administrator who can change Tier0 data)
    n61:  User-Tier1 (Access to administer or change HBI data)
    n62:  User-Tier2 (Access to non-public data)

  .EXAMPLE 
  Give an example of how to use it 
  .EXAMPLE 
  Give another example of how to use it 
  .PARAMETER VNETSite
  THe VNETSite will be passed and this function will cycle through the subnets of the VNET to create an N
  NSG Group and the default rules associated with the name in the subnet number. 
  .PARAMETER logname 
  The name of a file to write failed computer names to. Defaults to errors.txt. 
  #> 
  [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')] 
  param 
  ( 
    [Parameter(Mandatory=$True, 
    ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True, 
      HelpMessage='What VNETSite would you like to establish NSG rules for?')] 
    [Alias('VNETNSGConfig')] 
    [Object] $VNETSite,
    [string]$logname = 'errors.txt' 
  ) 
 
  begin { 
 $LogPath= $WorkingPath +$logname
 write-verbose "Deleting $logpath" 
    del $LogPath -ErrorActionSilentlyContinue 
  } 
 
  process { 
 
    write-verbose "Beginning process loop" 
#Test 



function NSGDefaultRules { 
  <# 
  .SYNOPSIS 
 This function will put the default NSG rules for a subnet while associating those rules to the specific 
 Subnet.
  .DESCRIPTION 
 The AzureFoundation pattern is a prescription of five subscriptions that interconnect with each other.  The 
 logic to seperate environment into five subscriptions is justified by security and lifecycle management. Each 
 subnet has a naming convention that includes the subnet number:
    100:  Prod
    200:  CJIS or HBI data
    300:  TEST
    400:  DEV
    500:  Storage
    600:  Services Tier0 data
 The other numbers in the subnet numbers follow this convention.
    n00:  Tier0 Data
    n10:  Web
    n20:  App
    n30:  Database
    n50:  DMZ
    n60:  User Tier0 (administrator who can change Tier0 data)
    n61:  User-Tier1 (Access to administer or change HBI data)
    n62:  User-Tier2 (Access to non-public data)

  .EXAMPLE 
  Give an example of how to use it 
  .EXAMPLE 
  Give another example of how to use it 
  .PARAMETER VNETSite
  THe VNETSite will be passed and this function will cycle through the subnets of the VNET to create an N
  NSG Group and the default rules associated with the name in the subnet number. 
  .PARAMETER logname 
  The name of a file to write failed computer names to. Defaults to errors.txt. 
  #> 
  [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')] 
  param 
  ( 
    [Parameter(Mandatory=$True, 
    ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True, 
      HelpMessage='What VNETSite would you like to establish NSG rules for?')] 
    [Alias('VNETNSGConfig')] 
    [Object] $VNETSite,
    [string]$logname = 'errors.txt' 
  ) 
 
  begin { 
 $LogPath= $WorkingPath +$logname
 write-verbose "Deleting $logpath" 
    del $LogPath -ErrorActionSilentlyContinue 
  } 
 
  process { 
 
    write-verbose "Beginning process loop" 
#Test 


    foreach($subnet in $VNETSite.subnets)
    {
        if($subnet.Name -Match "110")
            {
            $LNS.VPNGatewayAddress=$VPNGW_Services1.VIPAddress
            }
        If($LNS.name=$VNETName_Services2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Services2.VIPAddress
            }
        If($LNS.name=$VNETName_Storage1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Storage1.VIPAddress
            }
        If($LNS.name=$VNETName_Storage2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Storage2.VIPAddress
            }
        If($LNS.name=$VNETName_PreProd1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_PreProd1.VIPAddress
            }
        If($LNS.name=$VNETName_PreProd2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_PreProd2.VIPAddress
            }
        If($LNS.name=$VNETName_Prod1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Prod1.VIPAddress
            }
        If($LNS.name=$VNETName_Prod2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_Prod2.VIPAddress
            }
        If($LNS.name=$VNETName_CJIS1)
            {
            $LNS.VPNGatewayAddress=$VPNGW_CJIS1.VIPAddress
            }
        If($LNS.name=$VNETName_CJIS2)
            {
            $LNS.VPNGatewayAddress=$VPNGW_CJIS2.VIPAddress
            }
      } 
$VNETXML.save($XMLPath)
    } 
  } 


#
#Services
#
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
$VNETSite_Services1 = Get-AzureVNetSite -VNetName $vnetname_Srevices1
$VNETSite_Services2 = Get-AzureVNetSite -VNetName $vnetname_Srevices2

#Create a Network Security Group
New-AzureNetworkSecurityGroup -Name "NSG_APP_120" -Location $VNETSite_services1.location -Label "DMZ NSG SEVNET"

#Add, Update Rules to a NSG
Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Set-AzureNetworkSecurityRule -Name RDPInternet-DMZ -Type Inbound -Priority 347 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '63389' -DestinationAddressPrefix '10.0.2.0/25' -DestinationPortRange '63389' -Protocol TCP

#Delete a rule from NSG
Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Remove-AzureNetworkSecurityRule -Name RDPInternet-DMZ

#Associate a NSG to a Virtual machine
Get-AzureVM -ServiceName "Proxy01" -Name "azproxy01" | Set-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "DMZ_NSG"

#Remove a NSG from a VM
Get-AzureVM -ServiceName "Proxy01" -Name "azproxy01" | Remove-AzureNetworkSecurityGroupConfig -NetworkSecurityGroupName "DMZ_NSG"

#Associate a NSG to a subnet
Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName 'SEVNET' -SubnetName 'Azure DMZ Subnet'

#Remove a NSG from the subnet
Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" | Remove-AzureNetworkSecurityGroupFromSubnet -VirtualNetworkName 'SEVNET' -SubnetName 'Azure DMZ Subnet'

#Delete a NSG
Remove-AzureNetworkSecurityGroup -Name "DMZ_NSG"

#Get Details of Network Secuirty group along with rules
Get-AzureNetworkSecurityGroup -Name "DMZ_NSG" -Detailed