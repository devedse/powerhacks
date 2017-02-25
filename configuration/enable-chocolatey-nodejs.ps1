param(
    [switch] $chocolatey,
    [switch] $nodejs
)

# Set machine policy unrestricted
$localMachinePolicy = Get-ExecutionPolicy
Write-Verbose "Machine policy is $localMachinePolicy"
Set-ExecutionPolicy Unrestricted
Write-Verbose "Setting machine policy to Unrestricted"

if ($chocolatey)
{
    # --------------------------------------------------------------------
    # Install Chocolatey
    # --------------------------------------------------------------------
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex
}

if ($nodejs -and $chocolatey)
{
    # --------------------------------------------------------------------
    # Install Nodejs through chocolatey
    # --------------------------------------------------------------------
    choco install nodejs.install -y
}

# Reset machine policy
Write-Verbose "Setting machine policy back to $localMachinePolicy"
Set-ExecutionPolicy $localMachinePolicy