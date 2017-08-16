$dt=get-date
$path='c:\temp\azure\roadmap\GetResourceProvidersByRegion08012017b.csv'
$ResourceProviders = Get-AzureRmResourceProvider -ListAvailable
$JSONResourceProvider = ConvertTo-Json -InputObject $ResourceProviders 
$ResourceProviders | Format-Table
$RPTable =@()
$i=0
Foreach($RP in $ResourceProviders) {

foreach($rptype in $rp.ResourceTypes){


write-output $rp.ProviderNamespace "," $rptype.ResourceTypeName "," ($rptype.Locations| Format-table)

}

#$RPTable += ((Get-AzureRmResourceProvider -ProviderNamespace $rp.ProviderNamespace).ResourceTypes)
#((Get-AzureRmResourceProvider -ProviderNamespace $rp.ProviderNamespace).ResourceTypes) | Export-Csv -Append -Path $path

}



