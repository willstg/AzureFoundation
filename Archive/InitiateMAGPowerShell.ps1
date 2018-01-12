
#Reset who you are and make sure the session knows you're Tenant @tenant.onmicrosoft.com


#Now get Azure PowerShell to point to the MAG (veruss the MAC)
#Tenant Specific Variables

$UserName=
$subID_CJIS=
$SubName_CJIS=
$subID_PreProd=
$subName_PreProd=
$SubID_Prod=
$SubName_Prod=
$SubID_Services=
$SubName_Services=
$SubID_Storage=
$SubName_Storage=
#Log into the ARM
Login-AzureRmAccount –Environment (Get-AzureRmEnvironment –Name AzureUSGovernment)
Get-AzureRmSubscription
Set-AzureRmContext -SubscriptionName $subName
#As new resource providers are added we capture them
$AzureRMProviders=Get-AzureRmResourceProvider -ListAvailable | format-table

#Log into the Classic
Add-AzureAccount -Environment AzureUSGovernment
Get-AzureSubscription  | Format-Table
#Set-AzureSubscription -SubscriptionName $SubName -SubscriptionId $SubID -Certificate $CertName -Environment 'AzureUSGovernment'
Select-AzureSubscription -SubscriptionName $SubName -Current
#What features are available in each location?
Get-AzureLocation -Verbose|export-csv -Path "c:\temp\AzureLocation9-1-16.csv"
$AzureLocations=Get-AzureLocation | Where-Object -Property "Name" -Like "USGOV*" 
#Sometimes you may wonder what version of the Azure SDK you have installed
Get-Module -ListAvailable 
