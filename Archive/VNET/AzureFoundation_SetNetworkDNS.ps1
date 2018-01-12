Select-AzureSubscription -SubscriptionName $SubName_HBI -Current
Get-AzureVnetConfig -ExportToFile $XML_HBI
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Get-AzureVnetConfig -ExportToFile $XML_Services
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
Get-AzureVnetConfig -ExportToFile $XML_Prod
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
Get-AzureVnetConfig -ExportToFile $XML_PreProd
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
Get-AzureVnetConfig -ExportToFile $XML_Storage

#after you get the latest config files, you'll need to modify the DNS servers with teh 
#servers that are your domain contollers.
Select-AzureSubscription -SubscriptionName $SubName_HBI -Current
Set-AzureVNetConfig -ConfigurationPath $XML_HBI

Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Set-AzureVNetConfig -ConfigurationPath $XML_Services

Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
Set-AzureVNetConfig -ConfigurationPath $XML_Prod

Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
Set-AzureVNetConfig -ConfigurationPath $XML_PreProd

Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
Set-AzureVNetConfig -ConfigurationPath $XML_Storage
