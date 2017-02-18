cls

# define VM name
$prefix = "ME"
$env = "Staging"
$vmName = "$prefix$env"
$templateFile = "templates\octopus-tentacle-webserver.json"

# define resource group template file and params
$templateFilePath = (Split-Path $MyInvocation.MyCommand.Path) + "\$templateFile"
$templateParams = @{ 
    vmName=$vmName;
    vmUser='me';
    vmPass='ModernEngineering!';   
    octopusUrl='http://geuze-me.westeurope.cloudapp.azure.com';
    octopusApi='API-QJZX2G7AJ6N1DYDYITECMDX1OQY';
    octopusEnv=$env;
}

# login to Azure Resource Manager
try {get-azureRmContext} catch {Login-AzureRmAccount}

# In case more than one subscription available, guide to select the proper subscription
$m = Get-AzureRmSubscription | measure | select Count

if ($m.Count -gt 1) 
{
    Write-Host "you have more than one subscription, please select the one you want to use"
    Get-AzureRmSubscription
    $selectedSubscription = get-azureRmContext | Select Subscription

    Write-Host "selected: "
    Write-Host $selectedSubscription

    Get-AzureRmSubscription | where-Object {$_.SubscriptionId -eq $selectedSubscription}
    Write-Host Get-AzureRmSubscription | where-Object {$_.SubscriptionId -eq $selectedSubscription} | select SubscriptionName
    $subscriptionId = Read-Host "Insert the subscriptionID Leave blank to leave the current selected subscription"
}

$nullValue = [String]::IsNullOrEmpty($subscriptionId)

if ($nullValue -ne "true")
{
    Select-AzureRmSubscription -SubscriptionId $subscriptionId
}

write-host "you are using the following subscription: "

Get-AzureRmContext
Get-AzureRmContext | Select Subscription

# create the deploy resource group, if it does not exist already
New-AzureRmResourceGroup -Name $vmName -Location 'westeurope' -Force

# deploy using the resource group template
Write-Host 'Deploying... This might take a few minutes...' -ForegroundColor Yellow
New-AzureRmResourceGroupDeployment -Name $vmName -ResourceGroupName $vmName -TemplateFile $templateFilePath -TemplateParameterObject $templateParams -ErrorVariable 'deployError' -Verbose

# output result
if ($deployError -ne $null) {
    Write-Host 'Deployment error: ' -ForegroundColor Yellow -NoNewline 
    Write-Host $deployError -ForegroundColor Red
    Write-Host 'Inner error: ' -NoNewline -ForegroundColor Yellow
    Write-Host $deployError.Exception.Response.ReasonPhrase -ForegroundColor Red
    Write-Host $deployError.Exception.Response.Content -ForegroundColor Red
}
Write-Host 'Ready.' -ForegroundColor Yellow