$location="usgovvirginia"
$Publishers=Get-AzureRmVMImagePublisher -location $Location
foreach($publisher in $Publishers.PublisherName){

$Offers=Get-AzureRmVMImageOffer -location $location -PublisherName $publisher

foreach($offer in $Offers.Offer){

$SKUs=Get-AzureRmVMImageSku -Location $Location -Offer $offer -PublisherName $publisher

foreach($SKU in $SKUs.skus){
$Images=Get-AzureRmVMImage -Location $location -offer $offer -PublisherName $publisher -skus $Sku 

$images|Export-Csv -Append -Path c:\temp\azure\magImagesMarch2017.csv

}}}