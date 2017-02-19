# define VM name
$prefix = "ME"
$env = "Staging"
$vmName = "$prefix$env"

$templateFile = "templates\webserver-octopusdeploy.json"

$templateParameters = @{ 
    vmName=$vmName;
    vmUser='me';
    vmPass='ModernEngineering!';   
    octopusUrl='http://geuze-me.westeurope.cloudapp.azure.com';
    octopusApi='API-QJZX2G7AJ6N1DYDYITECMDX1OQY';
    octopusEnv=$env;
}

& ..\deploy-template.ps1 `
    -resourceGroupName $vmName `
    -templateFile $templateFile `
    -templateParameters $templateParameters