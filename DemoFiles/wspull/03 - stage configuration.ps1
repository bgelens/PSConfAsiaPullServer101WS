# download required module
Install-Module -Name ComputerManagementDsc -Scope CurrentUser -Force

# configuration
configuration baseConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
    Import-DscResource -ModuleName ComputerManagementDsc

    Node baseConfig {
        TimeZone SingaporeTime {
            IsSingleInstance = 'Yes'
            TimeZone = 'Singapore Standard Time'
        }
    }
}

# compile
baseConfig -OutputPath C:\pullserver\Configuration

# create checksum
New-DscChecksum -Path C:\pullserver\Configuration\baseConfig.mof -Force

# pull configuration