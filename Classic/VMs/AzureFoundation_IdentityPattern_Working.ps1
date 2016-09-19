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
    AzureFoundation_CreateIdentityPattern.ps1 
 Description:
    The prescriptive pattern of the AzureFoundation Identity Pattern

    Start:  The AzureFoundation_CreateVNET pattern has been applied to the environment.  There is a 'services'
    subscription where these VMs will be deployed.  THis script will be customized by replacing the Account
    with the account used for the subscriptions.  To customize the script, search and replace the name
    according to the naming convention.  For example, the location where the Domain Services will be deployed
    by default it may be "va".  The location is imbedded in the server name, the subnet name and maybe the resource
    group/cloud service.  The account name will replace "dept".  The 

    End:  The Domain Services pattern servers will be deployed in the Services subscription.
 VERSION: 
    0.1
Author:  willstg@msn.com
------------------------------------------------------------------------------ 
#>
$Environment = 'AzureUSGovernment'
#$Environment = 'AzureCloud'

$cred_Services = Get-Credential -message 'Internal Server Credentials'
$cred_DMZ = Get-Credential -Message 'DMZ Server Credentials'

$Path="C:\Temp\hasaz\"
$Location='USGov Iowa'
$VMimage=(Get-AzureVMImage | Where { $_.Label -match 'Windows Server 2012 R2 Datacenter, August 2016' } | Sort-Object PublishedDate)[-1]
$SubnetOct1="172"
$SubnetOct2="23"
$Dept="ext"
$Site1="st1"
$site2="st2"
#ServicesSubNet
$VNETName_Services1= 'mag_external_managed_services_IA'
$VNETName_Services2= 'mag_external_managed_services_VA'
$DCSUBNET="Services_600_dept_Srvcs_IA"
$DISKSIZEAD=24
#Domain Controllers
$IP_DC1a=$subnetOct1+'.'+$subnetoct2+'.120.11'
$IP_DC1b=$subnetOct1+'.'+$subnetoct2+'.120.12'
$AG_DC1="ActiveDirectory"
$AGD_DC1="ActiveDirectoryDomainAndFederationServices"
#CloudService Name (ResourceGroup Name)
$CS_DC1=$dept+$Site1+"padds1" #Add the ext name with no a or b instances
$VM_DC1a=$Site1+"padds1a"
$VM_DC1b=$site1+"padds1b"
$Size_DC="Small"
#$size_DC=$vmimage.RecommendedVMSize

#ADFS Servers
$IP_ADFS1a=$subnetOct1+'.'+$subnetoct2+'.120.13'
$IP_ADFS1b=$subnetOct1+'.'+$subnetoct2+'.120.14'
$ILB_ADFS1=$subnetOct1+'.'+$subnetoct2+'.120.15'
$ILBN_ADFS1 ="ILBForADFSFarm"
$CS_ADFS1=$dept+$Site1+"padfs1"  #Add the ext name with no a or b instances
$VM_ADFS1a=$Site1+"padfs1a"
$VM_ADFS1b=$Site1+"padfs1b"
$SIZE_ADFS="Small"
#$size_ADFS=$vmimage.RecommendedVMSize


#AADConnect
$IP_AADConnect1a=$subnetOct1+'.'+$subnetoct2+'.120.16'
$CS_aadConnect1=$dept+$site1+'paads1' #Add the ext name with no a or b instances
$VM_AADConnect1a=$site1+"paads1a"
$SIZE_AADConnect="Small"
#$size_AADConnect=$vmimage.RecommendedVMSize

#ServicesDMZSubnet
$PRXYSUBNET="DMZ_650_dept_Srvcs_ia"

#Proxy
$IP_WAP1a=$subnetOct1+'.'+$subnetoct2+".122.11"
$IP_WAP1b=$subnetOct1+'.'+$subnetoct2+".122.12"
$CS_WAP1=$dept1+$site1+"pprxy1"
$VM_WAP1a=$site1+"pprxy1a"
$VM_WAP1b=$Site1+"pprxy1b"
$ResIP_WAP1=$Dept+"ReservedIPForWAP"
$ResIP_Wap1_Desc="WAP Public IP Address"
$Size_WAP="Small"
#$size_WAP=$vmimage.RecommendedVMSize

#Disks 
$DISKLABEL="data"
$LUN=0
$hcaching="None"



#Make Sure Azure Subscription is set up

Get-AzureSubscription -SubscriptionId $SubID_Services
#Set-AzureRmContext -SubscriptionId $SubID_Services

Select-AzureSubscription -SubscriptionName $SubName_Services -Current


#Set Storage Account
#OS Storage Account
$osStorageAccountName='st1extservicesosa'
$OSSTORAGE=Get-AzureStorageAccount -StorageAccountName $OSStorageAccountName -ErrorAction SilentlyContinue
if ($osStorage -eq $null)
{	
New-AzureStorageAccount -StorageAccountName $osStorageAccountName -Location $location -type Standard_LRS
$osStorage = Get-AzureStorageAccount -StorageAccountName $osStorageAccountName
}
$osStorageKey = (Get-AzureStorageKey -StorageAccountName $osStorageAccountName).Primary
#Environment is AzureUSGovernment
$osStorageContext = New-AzureStorageContext  –StorageAccountName $OSStorageAccountName `
	-StorageAccountKey $OSStorageKey -Environment $Environment

if ((Get-AzureStorageContainer -Context $osStorageContext -Name vhds -ErrorAction SilentlyContinue) -eq $null)
{
    New-AzureStorageContainer -Context $osStorageContext -Name vhds
}
Set-AzureSubscription -SubscriptionId $SubID_Services -CurrentStorageAccountName $OSStorageAccountName

#Data Storage Account
$DataStorageAccountName=$site1+$dept+'servicesdataa'
$DataSTORAGE=Get-AzureStorageAccount -StorageAccountName $DataStorageAccountName -ErrorAction SilentlyContinue
if ($DataStorage -eq $null)
{	
New-AzureStorageAccount -StorageAccountName $DataStorageAccountName -Location $location -type Standard_LRS
$DataStorage = Get-AzureStorageAccount -StorageAccountName $dataStorageAccountName
New-AzureStorageContainer -Name vhds
}
$DataStorageKey = (Get-AzureStorageKey -StorageAccountName $DataStorageAccountName).Primary
$dataStorageContext = New-AzureStorageContext  –StorageAccountName $dataStorageAccountName `
	-StorageAccountKey $dataStorageKey -Environment $Environment
if ((Get-AzureStorageContainer -Context $dataStorageContext -Name vhds -ErrorAction SilentlyContinue) -eq $null)
{
    New-AzureStorageContainer -Context $dataStorageContext -Name vhds
}

#DC1
#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHH")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMdd")
$osfulldisklabel = $CS_DC1 + "-" + $VM_DC1a + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_DC1 + "-" + $VM_DC1a + "-" + $LUN + "-" + $DDdate

$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists
if (-not(Get-AzureAffinityGroup -Name $AG_DC1 -ErrorAction SilentlyContinue))  
		{
			#Create the availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_DC1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
            $VMCFG1=New-AzureVMConfig -Name $VM_DC1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}
$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $DCSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_DC1a
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
#Check if specified Cloud Service already exists
if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_dc1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	    New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_dc1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_DC1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1

#DC2----------------------

#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_DC1 + "-" + $VM_DC1b + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_DC1 + "-" + $VM_DC1b + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))  
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_DC1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
            $VMCFG1=New-AzureVMConfig -Name $VM_DC1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $DCSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_DC1b
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
		if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_dc1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_dc1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_DC1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1

#ADFS1
#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_ADFS1 + "-" + $VM_ADFS1a + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_ADFS1 + "-" + $VM_ADFS1a + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists (THis will be the same for all Active Directory servers)
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))  
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_ADFS1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
            $VMCFG1=New-AzureVMConfig -Name $VM_ADFS1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $DCSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_ADFS1a
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
		if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_adfs1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_adfs1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_adfs1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1


#ADFS2--------------------------
#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_ADFS1 + "-" + $VM_ADFS1b + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_ADFS1 + "-" + $VM_ADFS1b + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists (THis will be the same for all Active Directory servers)
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))  
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_ADFS1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
{
            $VMCFG1=New-AzureVMConfig -Name $VM_ADFS1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $DCSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_ADFS1b
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
		if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_adfs1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_adfs1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_adfs1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1
#Set up the ILB
Add-AzureInternalLoadBalancer -ServiceName $cs_adfs1 -InternalLoadBalancerName $ILBN_ADFS1 -SubnetName $DCSubnet -StaticVNetIPAddress $ILB_ADFS1


#AADConnect---------------------------

#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_AADConnect1 + "-" + $VM_AADConnect1a + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_AADConnect1 + "-" + $VM_AADConnect1a + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists (THis will be the same for all Active Directory servers)
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))  
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_AADConnect1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
$VMCFG1=New-AzureVMConfig -Name $VM_AADConnect1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $DCSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_AADConnect1a
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
	if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_AADConnect1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_AADConnect1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_AADConnect1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1


#-----------------------------
#WAP1
#Define Reserve IP Addresses for WAP
$ResWAPIP = Get-AzureReservedIP -ReservedIPName $ResIP_WAP1
if ($ResWAPIP -eq $Null)
{
New-AzureReservedIP -Location $Location -ReservedIPName $ResIP_WAP1 -Label $ResIP_WAP1_Desc
$ResWAPIP = Get-AzureReservedIP -ReservedIPName $ResIP_WAP1
}

#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_WAP1 + "-" + $VM_WAP1a + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_ADFS1 + "-" + $VM_WAP1a + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists (THis will be the same for all Active Directory servers)
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_WAP1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
            $VMCFG1=New-AzureVMConfig -Name $VM_WAP1a -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $PRXYSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_WAP1a
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
		if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $cs_WAP1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $cs_WAP1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_WAP1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1
#There has to be one deployment before associating the ReservedIP.
Set-AzureReservedIPAssociation -ReservedIPName $RESIP_WAP1 -ServiceName $CS_WAP1

#WAP2--------------------------
#VHD Name Setup
#CDRIVE
$date = Get-Date
		#Get date / time stamp for OS disk label
		$OSdate = $date.ToString("yyyyMMddHHmmssfff")

		#Get date / time stamp for DD disk label
		$date = $date.AddSeconds(10)	#original code had a 10 second sleep. 
		$DDdate = $date.ToString("yyyyMMddHHmmssfff")
$osfulldisklabel = $CS_WAP1 + "-" + $VM_WAP1b + "-" + "0" + "-" + $OSdate

#LUN0 Drive
	
		$ddfulldisklabel = $CS_WAP1 + "-" + $VM_WAP1b + "-" + $LUN + "-" + $DDdate


$OSMedia=$OSSTORAGEContext.BlobEndpoint+"vhds/"+$osfulldisklabel + ".vhd"
$DataMedia=$dataStorageContext.BlobEndPoint+"vhds/"+$ddfulldisklabel + ".vhd"
$MaxDisks = Get-AzureRoleSize | Where { $_.InstanceSize –eq $Size_DC} | Format-Table
#Check if specified Affinity Group already exists (THis will be the same for all Active Directory servers)
if (-not(Get-AzureAffinityGroup -Name $AG_DC1))  
		{
			#Create the config object with availability set
			New-AzureAffinityGroup -Name $AG_DC1 -Label $AGD_DC1 -Location $Location
            $VMCFG1=New-AzureVMConfig -Name $VM_WAP1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia -AvailabilitySetName $AG_DC1
        }
else
        {
            $VMCFG1=New-AzureVMConfig -Name $VM_WAP1b -InstanceSize $Size_DC -ImageName $vmimage.ImageName -MediaLocation $OSMedia 
		}

$VMCFG1 | Add-AzureProvisioningConfig -Windows -AdminUsername $cred_Services.GetNetworkCredential().Username -Password $cred_Services.GetNetworkCredential().Password
$VMCFG1 | Set-AzureSubnet -SubnetNames $PRXYSUBNET
$VMCFG1 | Set-AzureStaticVNetIP -IPAddress $IP_WAP1b
$VMCFG1 | Add-AzureDataDisk -CreateNew -DiskSizeInGB $DISKSIZEAD -DiskLabel $DISKLABEL -LUN $LUN -HostCaching $hcaching -MediaLocation $dataMedia
		
#Check if specified Cloud Service already exists
		if (-not(Get-AzureService | Where-Object {$_.ServiceName -eq $CS_WAP1}))
		{
			#If it does not exist, create Cloud Service before provisioning VM
	        New-AzureService -AffinityGroup $AG_DC1 -ServiceName $CS_WAP1
            Set-AzureReservedIPAssociation -ReservedIPName $RESIP_WAP1 -ServiceName $CS_WAP1
		}
New-AzureVM -vms $VMCFG1 -ServiceName $CS_WAP1 -Location $Location -VNetName $VNetName_Services1 -AffinityGroup $AG_DC1
