
Login-AzureRmAccount -Environment 'AzureUSGovernment'
$subscription = Get-AzureRmSubscription |  Out-GridView -PassThru
Set-AzureRmContext -SubscriptionId $subscription.Id
Write-Host "Successfully logged in to Azure." -ForegroundColor Green 
$VMS = Get-AzureRmVM 

Foreach($VM in $VMS)
{
    if($Vm[0].AvailabilitySetReference){}

#Get the current VM's NIC name to get the NIC variable set so the picklist of Subnets will allow the user to have an idea where the NIC was

    $NicName = (($VM.NetworkProfile.NetworkInterfaces[0].id).Split('/'))[8]
    $Nic = Get-AzureRmNetworkInterface -Name $NicName -ResourceGroupName $VM.ResourceGroupName
    $Title = (($NIC[0].IpConfigurations.subnet.id).split('/'))[10]

    $NewNetwork = Get-AzureRmVirtualNetwork |Select-Object -property Name,Location,ResourceGroupName,AddressSpacetext | Out-GridView -passthru
    $NewNetwork = Get-AzureRmVirtualNetwork -Name $NewNetwork.Name -ResourceGroupName $NewNetwork.ResourceGroupName

    $NewSubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $NewNetwork | Select-Object -Property Name,AddressPrefix |Out-GridView -PassThru -Title $Title
    $NewSubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $NewNetwork -Name $NewSubnet.Name
    
    $message = "current name: " + $vm.name + ", Current IP: " +$NIC[0].IpConfigurations.privateIPAddress+ ", New IP must be in this prefex: " + $NewSubnet.AddressPrefix


    $NewPrivateIP = Read-Host $message

    $NewIPConfig = New-AzureRmNetworkInterfaceIpConfig -SubnetId $NewSubnet.Id -Name 'config1' -Primary -PrivateIpAddress $NewPrivateIP -PublicIpAddressId 

    $NewNic = New-AzureRmNetworkInterface -Name "$($NicName)1a" -ResourceGroupName $Nic.ResourceGroupName `
                                          -Location $Nic.Location -IpConfiguration $NewIPConfig -Force
   

   #using the VM Configuration in memory, remove the primary NIC and replace with the new NIC
    Remove-AzureRmVMNetworkInterface -VM $VM -NetworkInterfaceIDs $NewNic.Id

    Add-AzureRmVMNetworkInterface -VM $VM -NetworkInterface $NewNic

    Stop-AzureRmVM -Name $VM.Name -ResourceGroupName $Vm.ResourceGroupName -Force
    Remove-AzureRmVM -Name $VM.Name -ResourceGroupName $Vm.ResourceGroupName -Force
     New-AzureRmVM -Name $VM.Name -ResourceGroupName $Vm.ResourceGroupName

       #   New-AzureRmVM -Name $VM.Name -ResourceGroupName 'rg-ActiveDirectoryDomainServices-tx'
       #    Stop-AzureRmVM -Name $VM.Name -ResourceGroupName 'rg-ActiveDirectoryDomainServices-tx' -Force
    #Remove-AzureRmVM -Name $VM.Name -ResourceGroupName 'rg-ActiveDirectoryDomainServices-tx' -Force
 #$newVM = Get-azurermVM -Name $VM.Name -ResourceGroupName 'rg-ActiveDirectoryDomainServices-tx'
    Start-AzureRmVM -Name $VM.Name -ResourceGroupName $Vm.ResourceGroupName
  $newVM = Get-azurermVM -Name $VM.Name -ResourceGroupName $Vm.ResourceGroupName
   $newVM.NetworkProfile.NetworkInterfaces[0].Id
}


