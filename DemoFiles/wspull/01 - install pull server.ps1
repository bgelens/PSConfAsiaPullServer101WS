# install xPSDesiredStateConfiguration
Install-Module -Name xPSDesiredStateConfiguration -RequiredVersion 8.4.0.0 -Force -Scope AllUsers

# create DSC configuration to install the Pull Server
configuration PullServerSQL {
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 8.4.0.0

    WindowsFeature dscservice {
        Name   = 'Dsc-Service'
        Ensure = 'Present'
    }

    File PullServerFiles {
        DestinationPath = 'c:\pullserver'
        Ensure = 'Present'
        Type = 'Directory'
        Force = $true
    }

    xDscWebService PSDSCPullServer {
        Ensure                       = 'Present'
        EndpointName                 = 'PSDSCPullServer'
        Port                         = 8080
        PhysicalPath                 = "$env:SystemDrive\inetpub\PSDSCPullServer"
        CertificateThumbPrint        = 'AllowUnencryptedTraffic'
        ModulePath                   = "c:\pullserver\Modules"
        ConfigurationPath            = "c:\pullserver\Configuration"
        State                        = 'Started'
        RegistrationKeyPath          = "c:\pullserver"
        UseSecurityBestPractices     = $false
        SqlProvider                  = $true
        SqlConnectionString          = 'Provider=SQLOLEDB.1;Server=localhost;Database=DSC;User ID=sa;Password=Welkom01;Initial Catalog=master;'
        DependsOn                    = '[File]PullServerFiles', '[WindowsFeature]dscservice'
    }

    File RegistrationKeyFile {
        Ensure          = 'Present'
        Type            = 'File'
        DestinationPath = "c:\pullserver\RegistrationKeys.txt"
        Contents        = 'cb30127b-4b66-4f83-b207-c4801fb05087'
        DependsOn       = '[File]PullServerFiles'
    }
}

# compile
PullServerSQL

# run
Start-DscConfiguration .\PullServerSQL -Wait -Verbose

# create db :)
Invoke-WebRequest -Uri http://localhost:8080/PSDSCPullServer.svc -UseBasicParsing

# see web.config
([xml](Get-Content -Path C:\inetpub\PSDSCPullServer\web.config)).configuration.appsettings.GetEnumerator()