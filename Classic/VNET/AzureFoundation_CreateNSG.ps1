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

$VNETName_Services1= "mag_capgem_managed_services_VA"
$VNETName_Services2= "mag_capgem_managed_services_IA"
$VNETName_Storage1= "mag_capgem_managed_storage_VA"
$VNETName_Storage2= "mag_capgem_managed_storage_IA"
$VNETName_PreProd1= "mag_capgem_managed_PreProd_VA"
$VNETName_PreProd2= "mag_capgem_managed_PreProd_IA"
$VNETName_CJIS1= "mag_capgem_managed_CJIS_VA"
$VNETName_CJIS2= "mag_capgem_managed_CJIS_IA"
$VNETName_Prod1= "mag_capgem_managed_Prod_VA"
$VNETName_Prod2= "mag_capgem_managed_Prod_IA"
$WorkingPath='c:\temp\CapGem\'
$Path="c:\temp\CapGem\"
$date = Get-Date
$filedate = $date.ToString("yyyyMMdd")

$WorkingPath='c:\temp\dept\'
$Path="c:\temp\dept\"
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
$VNETName_Services1= "mag_capgem_managed_services_VA"
$VNETName_Services2= "mag_capgem_managed_services_IA"

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
$VNETName_Storage1= "mag_capgem_managed_storage_VA"
$VNETName_Storage2= "mag_capgem_managed_storage_IA"
#PreProd Subscription
#

$ErrorLog_PreProd = $WorkingPath + "ErrorLog_PreProd"+$filedate+".txt"
$File_PreProd=$Path+"AzureFoundation_PreProd_Working.xml"
$XML_PreProd = $WorkingPath+"AzureFoundation_PreProd_Working.xml"
$VNETName_PreProd1= "mag_capgem_managed_PreProd_VA"
$VNETName_PreProd2= "mag_capgem_managed_PreProd_IA"
#Prod Subscription
#

$ErrorLog_Prod = $WorkingPath + "ErrorLog_Prod"+$filedate+".txt"
$File_Prod=$Path+"AzureFoundation_Prod_Working.xml"
$XML_Prod = $WorkingPath+"AzureFoundation_Prod_Working.xml"
$VNETName_Prod1= "mag_capgem_managed_Prod_VA"
$VNETName_Prod2= "mag_capgem_managed_Prod_IA"
$Backup_Prod=$WorkingPath+"AzureFoundation_Prod_Working.xml.backup"+$fileDate
#CJIS Subscription
#

$ErrorLog_CJIS = $WorkingPath + "ErrorLog_CJIS"+$filedate+".txt"
$File_CJIS=$Path+"AzureFoundation_CJIS_Working.xml"
$XML_CJIS = $WorkingPath+"AzureFoundation_CJIS_Working.xml"
$VNETName_CJIS1= "mag_capgem_managed_CJIS_VA"
$VNETName_CJIS2= "mag_capgem_managed_CJIS_IA"
$Backup_CJIS=$WorkingPath+"AzureFoundation_CJIS_Working.xml.backup"+$fileDate



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

            }
            }

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
$VNETSite_Services1 = Get-AzureVNetSite -VNetName $vnetname_Services1
$VNETSite_Services2 = Get-AzureVNetSite -VNetName $vnetname_Services2
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_660_dept_Srvcs_ia' -Location $VNETSite_PreProd2.location -Label '660: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Services_600_dept_Srvcs_va' -Location $VNETSite_Services1.location -Label '600: Services, Data Tier (0) Used to host highly s' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_650_dept_Srvcs_va' -Location $VNETSite_Services1.location -Label '650: DMZ, Data Tier (2) Used to host public facing' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_661_dept_Srvcs_va' -Location $VNETSite_Services1.location -Label '661: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Future_670_dept_Srvcs_va' -Location $VNETSite_Services1.location -Label '670: Future, Data Tier (0) Future Consideration' 
New-AzureNetworkSecurityGroup -Name 'NSG_Services_600_dept_Srvcs_ia' -Location $VNETSite_Services2.location -Label '600: Services, Data Tier (0) Used to host highly s' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_650_dept_Srvcs_ia' -Location $VNETSite_Services2.location -Label '650: DMZ, Data Tier (2) Used to host public facing' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_661_dept_Srvcs_ia' -Location $VNETSite_Services2.location -Label '661: Users_Tier1, Data Tier (1) Tier 1 administrat' 

#Storage
#
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
$VNETSite_Storage1 = Get-AzureVNetSite -VNetName $vnetname_Storage1
$VNETSite_Storage2 = Get-AzureVNetSite -VNetName $vnetname_Storage2
New-AzureNetworkSecurityGroup -Name 'NSG_Storage_500_dept_Storage_va' -Location $VNETSite_Storage1.location -Label '500: Storage, Data Tier (0) Storage appliances' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_560_dept_Storage_va' -Location $VNETSite_Storage1.location -Label '560: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_561_dept_Storage_va' -Location $VNETSite_Storage1.location -Label '561: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Storage_500_dept_Storage_ia' -Location $VNETSite_Storage2.location -Label '500: Storage, Data Tier (0) Future Consideration' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_560_dept_Storage_ia' -Location $VNETSite_Storage2.location -Label '560: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_561_dept_Storage_ia' -Location $VNETSite_Storage2.location -Label '561: Users_Tier1, Data Tier (1) Tier 1 administrat' 

#Prod
#
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
$VNETSite_Prod1 = Get-AzureVNetSite -VNetName $vnetname_Prod1
$VNETSite_Prod2 = Get-AzureVNetSite -VNetName $vnetname_Prod2
New-AzureNetworkSecurityGroup -Name 'NSG_Web_110_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '110: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_120_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '120: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_130_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '130: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_150_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '150: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_160_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '160: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_161_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '161: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_162_dept_prod_ia' -Location $VNETSite_Prod2.location -Label '162: Users_Tier2, Data Tier (2) Tier 2 - Control o' 
New-AzureNetworkSecurityGroup -Name 'NSG_Web_110_dept_prod_va' -Location $VNETSite_Prod1.location -Label '110: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_120_dept_prod_va' -Location $VNETSite_Prod1.location -Label '120: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_130_dept_prod_va' -Location $VNETSite_Prod1.location -Label '130: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_150_dept_prod_va' -Location $VNETSite_Prod1.location -Label '150: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_160_dept_prod_va' -Location $VNETSite_Prod1.location -Label '160: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_161_dept_prod_va' -Location $VNETSite_Prod1.location -Label '161: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_162_dept_prod_va' -Location $VNETSite_Prod1.location -Label '162: Users_Tier2, Data Tier (2) Tier 2 - Control o' 

#PreProd
#
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
$VNETSite_PreProd1 = Get-AzureVNetSite -VNetName $vnetname_PreProd1
$VNETSite_PreProd2 = Get-AzureVNetSite -VNetName $vnetname_PreProd2
New-AzureNetworkSecurityGroup -Name 'NSG_Web_310_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '310: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_320_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '320: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_330_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '330: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_350_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '350: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier0_360_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '360: Users_Tier0, Data Tier (0) Tier 0 - Direct Co' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_361_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '361: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_362_dept_Test_ia' -Location $VNETSite_PreProd2.location -Label '362: Users_Tier2, Data Tier (2) Tier 2 - Control o' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier0_363_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '363: Users_Tier0, Data Tier (0) Tier 0 - Direct Co' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_364_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '364: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_365_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '365: Users_Tier2, Data Tier (2) Tier 2 - Control o' 
New-AzureNetworkSecurityGroup -Name 'NSG_Web_410_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '410: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_420_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '420: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_430_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '430: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_450_dept_Dev_ia' -Location $VNETSite_PreProd2.location -Label '450: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_Web_310_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '310: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_320_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '320: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_330_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '330: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_350_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '350: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_360_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '360: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_361_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '361: Users_Tier1, Data Tier (1) Tier 1 administrat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_362_dept_Test_va' -Location $VNETSite_PreProd1.location -Label '362: Users_Tier2, Data Tier (2) Tier 2 - Control o' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_363_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '363: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier1_364_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '364: User_Tier1, Data Tier (1) Tier 1 administrato' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier2_364_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '364: User_Tier2, Data Tier (2) Tier 2 - Control of' 
New-AzureNetworkSecurityGroup -Name 'NSG_Web_410_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '410: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_420_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '420: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_430_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '430: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_450_dept_Dev_va' -Location $VNETSite_PreProd1.location -Label '450: DMZ, Data Tier (2) Internet EndPoint Machines' 

#
#CJIS
#
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
$VNETSite_CJIS1 = Get-AzureVNetSite -VNetName $vnetname_CJIS1
$VNETSite_CJIS2 = Get-AzureVNetSite -VNetName $vnetname_CJIS2
New-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '210: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '220: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_Database_230_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '230: Database, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '250: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '260: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier1_261_dept_CJIS_ia' -Location $VNETSite_CJIS2.location -Label '261: User_Tier1, Data Tier (1) Tier 1 administrato' 
New-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '210: Web, Data Tier (2) HTTP and HTTPS services' 
New-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '220: App, Data Tier (1) Web Services, OEM applicat' 
New-AzureNetworkSecurityGroup -Name 'NSG_DB_230_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '230: DB, Data Tier (1) Data for Applications' 
New-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '250: DMZ, Data Tier (2) Internet EndPoint Machines' 
New-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '260: User_Tier0, Data Tier (0) Tier 0 - Direct Con' 
New-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_261_dept_CJIS_va' -Location $VNETSite_CJIS1.location -Label '261: Users_Tier1, Data Tier (1) Tier 1 administrat' 


#
#Add, Update Rules to a NSG
#
#Services
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Services_600_dept_Srvcs_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_650_dept_Srvcs_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.58.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_661_dept_Srvcs_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Future_670_dept_Srvcs_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Services_600_dept_Srvcs_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_650_dept_Srvcs_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.122.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_660_dept_Srvcs_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_661_dept_Srvcs_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP




#Storage
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Storage_500_dept_Storage_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_560_dept_Storage_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_561_dept_Storage_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Storage_500_dept_Storage_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_560_dept_Storage_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_561_dept_Storage_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP


#Prod
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_110_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_120_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_130_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_150_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.8.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_160_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_161_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_162_dept_prod_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_110_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_120_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_130_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_150_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.70.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_160_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_161_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_162_dept_prod_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP


#PreProd
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_310_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_320_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_330_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_350_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.35.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_360_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_361_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_362_dept_Test_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_363_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier1_364_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier2_364_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_410_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_420_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_430_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_450_dept_Dev_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.43.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_310_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_320_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_330_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_350_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.99.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier0_360_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_361_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_362_dept_Test_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier0_363_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_364_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier2_365_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_410_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_420_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_430_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_450_dept_Dev_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.106.0/24' -DestinationPortRange '443' -Protocol TCP



#CJIS
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DB_230_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'HTTPS.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.22.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_261_dept_CJIS_va' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_230_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Allow' -Type Inbound -Priority 100 -Action Allow -SourceAddressPrefix 'INTERNET'  -SourcePortRange '443' -DestinationAddressPrefix '10.130.86.0/24' -DestinationPortRange '443' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier1_261_dept_CJIS_ia' | Set-AzureNetworkSecurityRule -Name 'All_Internet.Inbound.Deny' -Type Inbound -Priority 100 -Action Deny -SourceAddressPrefix 'INTERNET'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange '*' -Protocol TCP



#Associate NSG to Subnet
#Services
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Services_600_dept_Srvcs_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_Services1 -SubnetName 'Services_600_mag_capgem_Srvcs_VA'

$VNETSITE_CJIS = Get-AzureVNetSite -VNetName $VNETName_Services1
$VNETSite_CJIS.Subnets


#Storage
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current


#Prod
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current


#PreProd
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current



#CJIS
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'Web_210_mag_capgem_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'App_220_dept_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_DB_230_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'DB_230_dept_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'DMZ_250_dept_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'User_Tier0_260_dept_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_Users_Tier1_261_dept_CJIS_va' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS1 -SubnetName 'Users_Tier1_261_dept_CJIS_va'
Get-AzureNetworkSecurityGroup -Name 'NSG_Web_210_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'Web_210_dept_CJIS_ia'
Get-AzureNetworkSecurityGroup -Name 'NSG_App_220_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'App_220_dept_CJIS_ia'
Get-AzureNetworkSecurityGroup -Name 'NSG_Database_230_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'Database_230_dept_CJIS_ia'
Get-AzureNetworkSecurityGroup -Name 'NSG_DMZ_250_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'DMZ_250_dept_CJIS_ia'
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier0_260_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'User_Tier0_260_dept_CJIS_ia'
Get-AzureNetworkSecurityGroup -Name 'NSG_User_Tier1_261_dept_CJIS_ia' | Set-AzureNetworkSecurityGroupToSubnet -VirtualNetworkName $VNETName_CJIS2 -SubnetName 'User_Tier1_261_dept_CJIS_ia'

$AzureVNETSite_CJIS = Get-AzureVNetSite -VNetName $VNETName_CJIS1

$AzureVNETSite_CJIS.subnets


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