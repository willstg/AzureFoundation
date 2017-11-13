$site=4

$VPNGWResourceGroupName1 = "rg_vnet_services_W1"
$VPNGWName1 = "gw_Services_W1_Vpn"
$VPNGWResourceGroupName2 = "rg_vnet_services_W2"
$VPNGWName2 = "gw_Services_W2_Vpn"
$VPNGWResourceGroupName3 = "rg_vnet_services_TX"
$VPNGWName3 = "gw_Services_TX_Vpn"
$VPNGWResourceGroupName4 = "rg_vnet_services_AZ"
$VPNGWName4 = "gw_Services_AZ_Vpn"


if($site -eq 1){
$VPNGWResourceGroupName=$VPNGWResourceGroupName1
$VPNGWName=$VPNGWName1
}
if($site -eq 2){
$VPNGWResourceGroupName=$VPNGWResourceGroupName2
$VPNGWName=$VPNGWName2
}
if($site -eq 3){
$VPNGWResourceGroupName=$VPNGWResourceGroupName3
$VPNGWName=$VPNGWName3
}
if($site -eq 4){
$VPNGWResourceGroupName=$VPNGWResourceGroupName4
$VPNGWName=$VPNGWName4
}


#LocalNetworkConnection - The location we are connecting to's details.
$LocalGW = Get-AzureRmLocalNetworkGateway -ResourceGroupName $VPNGWResourceGroupName
#The VNET's Gateway, what allows traffic from other locations into the VNET
$VPNGW = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $VPNGWResourceGroupName
$VPNConnections = Get-AzureRmVirtualNetworkGatewayConnection -ResourceGroupName $VPNGWResourceGroupName
$VPNConnections
$VPNGWResourceGroupName

foreach($Connection in $VPNConnections){
Get-AzureRmVirtualNetworkGatewayConnection -ResourceGroupName $VPNGWResourceGroupName -name $Connection.name
$Connection
$Connection.Name

}

#Is Routing Working?
$VPNPeerStatus = Get-AzureRmVirtualNetworkGatewayBGPPeerStatus -ResourceGroupName $VPNGWResourceGroupName -VirtualNetworkGatewayName $VPNGWName
$VPNLearnedRoutes = Get-AzureRmVirtualNetworkGatewayLearnedRoute -ResourceGroupName $VPNGWResourceGroupName -VirtualNetworkGatewayName $VPNGWName



#Now can we see what happens between a Source and Destination IP?
$NIC1 =
$NIC2 =

#what do we want to see?
Write-output "gateway BGP:  " $VPNGW[0].BgpSettingsText
Write-Output "gateway.EnableBgp: "$VPNGW[0].EnableBgp
Write-Output "Connection BGP: "$VPNConnections[0].EnableBgp
Write-Output "connection Status: " $VPNConnections[0].TunnelConnectionStatus
Write-output "VPN Peer Status: " $VPNPeerStatus.Asn $VPNPeerStatus.Neighbor $VPNPeerStatus.State

$i=0
foreach ($BGPPeer in $VPNPeerStatus){

Get-AzureRmVirtualNetworkGatewayAdvertisedRoute -Peer $LocalGW.GatewayIpAddress -ResourceGroupName $VPNGWResourceGroupName -VirtualNetworkGatewayName $VPNGWName
$i=$1+1
}

#Actions



#Set-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $VPNGW[0] -Asn "65523"
$VPNConnections = Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $VPNConnections[0] -EnableBgp 1


#Reset-AzureRmVirtualNetworkGateway -VirtualNetworkGateway $VPNGW[1] 