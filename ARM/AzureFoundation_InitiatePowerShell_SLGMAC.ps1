
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
$subID_HBI='ce38c0ef-22f5-458d-b1f7-e3890e2471f2'
$SubName_HBI= 'MAC_Dept_Managed_HBI'
$subID_PreProd='36d14b3b-1138-4062-a82f-67fb1ea8f109'
$subName_PreProd='a7d928df-fc97-4f02-adae-3d7cdeb7c8cb'
$SubID_Prod='ec1cea2e-92aa-45a7-89b0-d9fc40df2beb'
$SubName_Prod='MAC_Organization_Managed_Prod'
$SubID_Services='730f26b5-ebf5-4518-999f-0b4eb0cdc8f9'
$SubName_Services='MAC_SLG_Managed_Services'
$SubID_Storage='6e5d19d2-a324-470a-b24f-57ac0d3221a1'
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

Get-AzureRmSubscription -TenantId '73f43ea-693f-4bae-ac7b-8e13a33709ec'
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

