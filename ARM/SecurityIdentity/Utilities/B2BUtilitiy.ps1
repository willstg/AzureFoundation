#$Environment = "AzureUSGovernment"
$Environment = 'AzureCloud'
$AADEnvironment = "USGovernment"
#$AADEnvironment = "AzureCloud"
Login-AzureRmAccount -EnvironmentName $Environment;
Connect-MsolService -AzureEnvironment $AADEnvironment
$SubID_Services="730f26b5-ebf5-4518-999f-0b4eb0cdc8f9"
$SubName_Services="MAC_SLG_Managed_Services"
Select-AzureRmSubscription -SubscriptionID $SubID_Services;

#MAC:  $SubID_Services="730f26b5-ebf5-4518-999f-0b4eb0cdc8f9"
$SubName_Services="MAC_SLG_Managed_Services"
$SubID_Services='30457dd5-e56b-416b-9228-d48b37fe7caa'
Select-AzureRmSubscription -SubscriptionID $SubID_Services;
#Change a guest to a Member
$users = get-msoluser -UserPrincipalName "tonydevo_microsoft.com#EXT#@Magtaggov.onmicrosoft.com"
foreach($User in $users)
{

#$user | Set-MsolUser -UserType Member
}

