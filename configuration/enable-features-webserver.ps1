param(
    [switch] $iis,
    [switch] $chocolatey,
    [switch] $webdeploy,
    [switch] $vsts,
    [switch] $nodejs
)

# Set machine policy unrestricted
$localMachinePolicy = Get-ExecutionPolicy
Write-Verbose "Machine policy is $localMachinePolicy"
Set-ExecutionPolicy Unrestricted
Write-Verbose "Setting machine policy to Unrestricted"

if ($iis)
{
    # --------------------------------------------------------------------
    # Define the variables.
    # --------------------------------------------------------------------
    $InetPubRoot = "C:\Inetpub"
    $InetPubLog = "C:\Inetpub\Logs"
    $InetPubWWWRoot = "C:\Inetpub\WWWRoot"

    # --------------------------------------------------------------------
    # Loading Feature Installation Modules
    # --------------------------------------------------------------------
    $Command = "icacls ..\ /grant ""Network Service"":(OI)(CI)W"
    cmd.exe /c $Command

    # --------------------------------------------------------------------
    # Loading IIS Modules
    # --------------------------------------------------------------------
    Import-Module ServerManager 

    # --------------------------------------------------------------------
    # Installing IIS
    # --------------------------------------------------------------------
    Add-WindowsFeature -Name Web-Common-Http,Web-Asp-Net,Web-Asp-Net45,Web-Net-Ext,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Http-Logging,Web-Request-Monitor,Web-Basic-Auth,Web-Windows-Auth,Web-Filtering,Web-Performance,Web-Mgmt-Console,Web-Mgmt-Compat,WAS -IncludeAllSubFeature

    # --------------------------------------------------------------------
    # Loading IIS Modules
    # --------------------------------------------------------------------
    Import-Module WebAdministration

    # --------------------------------------------------------------------
    # Setting directory access
    # --------------------------------------------------------------------
    $Command = "icacls $InetPubWWWRoot /grant BUILTIN\IIS_IUSRS:(OI)(CI)(RX) BUILTIN\Users:(OI)(CI)(RX)"
    cmd.exe /c $Command
    $Command = "icacls $InetPubLog /grant ""NT SERVICE\TrustedInstaller"":(OI)(CI)(F)"
    cmd.exe /c $Command

    # --------------------------------------------------------------------
    # Resetting IIS
    # --------------------------------------------------------------------
    $Command = "IISRESET"
    Invoke-Expression -Command $Command
}

if ($chocolatey)
{
    # --------------------------------------------------------------------
    # Install Chocolatey
    # --------------------------------------------------------------------
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

if ($webdeploy -and $chocolatey)
{
    # --------------------------------------------------------------------
    # Install MS Web Deploy through chocolatey
    # --------------------------------------------------------------------
    choco install webdeploy -y
}

if ($nodejs -and $chocolatey)
{
    # --------------------------------------------------------------------
    # Install Nodejs through chocolatey
    # --------------------------------------------------------------------
    choco install nodejs.install -y
}

if ($vsts)
{
    # --------------------------------------------------------------------
    # Install VSTS custom stuff
    # --------------------------------------------------------------------
    Write-Verbose "Installing VSTS Tools..."
    Write-Verbose "VSTS Tools successfully installed."
}

# Reset machine policy
Write-Verbose "Setting machine policy back to $localMachinePolicy"
Set-ExecutionPolicy $localMachinePolicy