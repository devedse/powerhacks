# define VM name
$prefix = "VSTS"
$env = "BuildDeploy"
$vmName = "$prefix$env"

$templateFile = "templates\webserver-vsts.json"

$templateParameters = @{ 
    vmName=$vmName;
    vmUser='me';
    vmPass='ModernEngineering!';   
}

& ..\deploy-template.ps1 `
    -resourceGroupName $vmName `
    -templateFile $templateFile `
    -templateParameters $templateParameters