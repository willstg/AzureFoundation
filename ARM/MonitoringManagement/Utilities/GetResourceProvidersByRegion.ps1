$dt=get-date
$path='c:\temp\azure\roadmap\GetResourceProvidersByRegion06302017.csv'
$ResourceProviders = Get-AzureRmResourceProvider -ListAvailable
$JSONResourceProvider = ConvertTo-Json -InputObject $ResourceProviders 
$ResourceProviders | Format-Table
$RPTable =@()
$i=0
Foreach($RP in $ResourceProviders) {


$RPTable += ((Get-AzureRmResourceProvider -ProviderNamespace $rp.ProviderNamespace).ResourceTypes)
((Get-AzureRmResourceProvider -ProviderNamespace $rp.ProviderNamespace).ResourceTypes) | Format-Table
}

$RPTable | Export-CSV

