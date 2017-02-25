configuration EnableIIS
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node "localhost"
    {
        # Install the Web Server role
        WindowsFeature WebServerRole
        {
            Name = "Web-Server"
            Ensure = "Present"
        }

        # Install the ASP.NET 4.5 role
        WindowsFeature WebAspNet45
        {
            Name = "Web-Asp-Net45"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]WebServerRole"
        }
        
        # Install the IIS Management Console
        WindowsFeature WebManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]WebServerRole"
        }

        # Script block to download WebPI MSI from the Azure storage blob
        Script DownloadWebPIImage
        {
            GetScript = {
                @{
                    Result = "WebPIInstall"
                }
            }

            TestScript = {
                Test-Path "C:\wpilauncher.exe"
            }

            SetScript ={
                $source = "http://go.microsoft.com/fwlink/?LinkId=255386"
                $destination = "C:\wpilauncher.exe"
                Invoke-WebRequest $source -OutFile $destination
            }
        }

        Package WebPi_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = "C:\wpilauncher.exe"
            ProductId = '4D84C195-86F0-4B34-8FDE-4A17EB41306A'
            Arguments = ''
            DependsOn = @("[Script]DownloadWebPIImage")
        }

        Package WebDeploy_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Deploy 3.6"
            Path = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
            ProductId = ''
            Arguments = "/install /products:ASPNET_REGIIS_NET4,WDeploy36  /AcceptEula"
            DependsOn = @("[Package]WebPi_Installation")
        }
    }
}
EnableIIS

Start-DscConfiguration ./EnableIIS -wait -Verbose -Force