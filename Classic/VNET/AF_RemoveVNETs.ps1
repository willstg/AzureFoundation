$VNETName_Services1= "dept_managed_services_VA"
$VNETName_Services2= "dept_managed_services_IA"
$VNETName_Storage1= "dept_managed_storage_VA"
$VNETName_Storage2= "dept_managed_storage_IA"
$VNETName_PreProd1= "dept_managed_PreProd_VA"
$VNETName_PreProd2= "dept_managed_PreProd_IA"
$VNETName_CJIS1= "dept_managed_CJIS_VA"
$VNETName_CJIS2= "dept_managed_CJIS_IA"
$VNETName_Prod1= "dept_managed_Prod_VA"
$VNETName_Prod2= "dept_managed_Prod_IA"

#
#Services
#
Select-AzureSubscription -SubscriptionName $SubName_Services -Current
Remove-AzureVNetGateway -vnetname $VNETName_Services1
Remove-AzureVNetGateway -vnetname $VNETName_Services2
Remove-AzureVNetConfig
#
#Storage
#
Select-AzureSubscription -SubscriptionName $SubName_Storage -Current
Remove-AzureVNetGateway -vnetname $VNETName_Storage1
Remove-AzureVNetGateway -vnetname $VNETName_Storage2
Remove-AzureVNetConfig
#
#Prod
#
Select-AzureSubscription -SubscriptionName $SubName_Prod -Current
Remove-AzureVNetGateway -vnetname $VNETName_Prod1
Remove-AzureVNetGateway -vnetname $VNETName_Prod2
Remove-AzureVNetConfig
#
#PreProd
#
Select-AzureSubscription -SubscriptionName $SubName_PreProd -Current
Remove-AzureVNetGateway -vnetname $VNETName_PreProd1
Remove-AzureVNetGateway -vnetname $VNETName_PreProd2
Remove-AzureVNetConfig
#
#CJIS
#
Select-AzureSubscription -SubscriptionName $SubName_CJIS -Current
Remove-AzureVNetGateway -vnetname $VNETName_CJIS1
Remove-AzureVNetGateway -vnetname $VNETName_CJIS2
Remove-AzureVNetConfig