param(
    $projecturl,
    $projectname,
    $pattoken,
    $deploymentgroupname,
    $deploymentgrouptags,
    $windowslogonaccount,
    $windowslogonpassword,
    $agentfolder = "vstsagent",
    $agentworkfolder = "_work"
)

$ErrorActionPreference="Stop"
$agentZip="$PSScriptRoot\agent.zip"

If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    throw "Run command in Administrator PowerShell Prompt"
}

If(Test-Path $env:SystemDrive\$agentfolder\config.cmd)
{
    cd "$env:SystemDrive\$agentfolder"
    .\config.cmd remove --auth PAT --token $pattoken
    cd "$PSScriptRoot"
    Remove-Item -Path "$env:SystemDrive\$agentfolder" -Recurse -Force -Confirm:$false

	Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, "$env:SystemDrive\$agentfolder")
}
Else
{
	Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($agentZip, "$env:SystemDrive\$agentfolder")
}

Remove-Item $agentZip

cd "$env:SystemDrive\$agentfolder"

.\config.cmd `
    --addmachinegrouptags `
    --machinegroup `
    --replace `
    --unattended `
    --runasservice `
    --auth PAT `
    --token $pattoken `
    --url "$projecturl" `
    --projectname "$projectname" `
    --agent $env:COMPUTERNAME `
    --work "$agentworkfolder" `
    --machinegroupname "$deploymentgroupname" `
    --machinegrouptags "$deploymentgrouptags" `
    --windowslogonaccount "$windowslogonaccount" `
    --windowslogonpassword "$windowslogonpassword"