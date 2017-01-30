
#Reset who you are and make sure the session knows you're Tenant @tenant.onmicrosoft.com


#Now get Azure PowerShell to point to the MAG (veruss the MAC)
#Tenant Specific Variables

#Now get Azure PowerShell to point to the MAG (veruss the MAC)
#Tenant Specific Variables
#$Environment = "AzureUSGovernment"
$Environment = 'AzureCloud'

$UserName='willst@slg044.onmicrosoft.com'
$subID_CJIS=
$SubName_CJIS=
$subID_HBI='ff485773-85a0-4471-8caf-62431bc8096f'
$SubName_HBI= 'MAC_Dept_Managed_HBI'
$subID_PreProd='36d14b3b-1138-4062-a82f-67fb1ea8f109'
$subName_PreProd='MAC_Organization_Managed_PreProd'
$SubID_Prod='4b404fbc-017c-4085-81b4-6249adc0fc30'
$SubName_Prod='MAC_Organization_Managed_Prod'
$SubID_Services='b8ac0f8b-3c6d-4d8f-976e-f4b613e68ef4'
$SubName_Services='MAC_SLG_Managed_Services'
$SubID_Storage='3cb57323-0c04-449a-b86f-add680595a81'
$SubName_Storage='MAC_Organization_Managed_Storage'

#sometimes it seems you can't switch back to MAC from MAG without getting rid of MAG accounts
$Remove = 1
$accounts = Get-AzureAccount
if ($remove -eq 1){
foreach ($acct in $accounts.id){
Remove-AzureAccount -name $acct -Force
}
}

#Log Into MAG
Login-AzureRmAccount –EnvironmentName $environment

Get-AzureRmSubscription -TenantId '7e3f43ea-693f-4bae-ac7b-8e13a33709ec'
#I like to make the default $subname = to the Services subscription
$subName=$SubName_Services

Set-AzureRmContext -SubscriptionName $subName
#As new resource providers are added we capture them

#Log into the Classic MAG
#Add-AzureAccount -Environment AzureUSGovernment
#Log into the Classic MAC
Add-AzureAccount -Environment $Environment
Get-AzureSubscription  | Format-Table

#Set-AzureSubscription -SubscriptionName $SubName -SubscriptionId $SubID -Certificate $CertName -Environment 'AzureUSGovernment'
Select-AzureSubscription -SubscriptionName $SubName -Current

