Select-AzureSubscription -SubscriptionName $SubName_Services -Current
$NSGToDelete = Get-AzureNetworkSecurityGroup
ForEach ($NSG in $NSGToDelete)
{Remove-AzureNetworkSecurityGroup -Name $NSG.name -Force}

Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
$NSGToDelete = Get-AzureNetworkSecurityGroup
ForEach ($NSG in $NSGToDelete)
{Remove-AzureNetworkSecurityGroup -Name $NSG.name -Force}

Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
$NSGToDelete = Get-AzureNetworkSecurityGroup
ForEach ($NSG in $NSGToDelete)
{Remove-AzureNetworkSecurityGroup -Name $NSG.name -Force}

Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
$NSGToDelete = Get-AzureNetworkSecurityGroup
ForEach ($NSG in $NSGToDelete)
{Remove-AzureNetworkSecurityGroup -Name $NSG.name -Force}

Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
$NSGToDelete = Get-AzureNetworkSecurityGroup
ForEach ($NSG in $NSGToDelete)
{Remove-AzureNetworkSecurityGroup -Name $NSG.name -Force}