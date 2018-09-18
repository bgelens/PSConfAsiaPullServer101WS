# update node config
configuration MySuperServer {
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1

    Node MySuperServer {
        File MySuperFile {
            Ensure = 'Present'
            DestinationPath = 'C:\Windows\Temp\MySuperFile.txt'
            Contents = 'PSConfASIA 2018 ROCKS!!!'
        }
    }
}
MySuperServer -OutputPath 'C:\pullserver\Configuration'
New-DscChecksum -Path 'C:\pullserver\Configuration\MySuperServer.mof' -Force

# overwrite configuration name server side
Get-DSCPullServerAdminRegistration | Set-DSCPullServerAdminRegistration -ConfigurationNames 'MySuperServer'
Get-DSCPullServerAdminRegistration

# pull new config