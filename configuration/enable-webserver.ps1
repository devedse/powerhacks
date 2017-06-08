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
    }
}
EnableIIS

Start-DscConfiguration ./EnableIIS -wait -Verbose -Force