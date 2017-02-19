﻿try { Get-AzureRmContext } catch { Login-AzureRmAccount }

$locName="West Europe"
#Get-AzureRMVMImagePublisher -Location $locName | Select PublisherName

$pubName="MicrosoftWindowsServer"
#Get-AzureRMVMImageOffer -Location $locName -Publisher $pubName | Select Offer

$offerName="WindowsServer"
Get-AzureRMVMImageSku -Location $locName -Publisher $pubName -Offer $offerName | Select Skus