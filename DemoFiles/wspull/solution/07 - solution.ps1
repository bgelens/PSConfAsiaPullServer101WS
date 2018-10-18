# fetch xCredSSP module
Install-Module -Name xCredSSP -Force -Scope CurrentUser

# prep module so LCMs can download
$version = (Get-Module xCredSSP -ListAvailable).Version.ToString()
Compress-Archive -Path C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\xCredSSP\$version\* -DestinationPath C:\pullserver\Modules\xCredSSP_$version.zip -Force
New-DscChecksum -Path C:\pullserver\Modules\xCredSSP_$version.zip  -Force

# stage configuration
configuration credsspsample {
    Import-DscResource -ModuleName xCredSSP

    Node BaseServerConfig {
        xCredSSP server {
            Role = 'Server'
            Ensure = 'Present'
            SuppressReboot = $true
        }
    }
}

credsspsample -OutputPath C:\pullserver\Configuration
New-DscChecksum -Path C:\pullserver\Configuration\BaseServerConfig.mof -Force

# assign configuration to node
$sqlCred = [pscredential]::new('sa', (ConvertTo-SecureString 'Welkom01' -AsPlainText -Force))
New-DSCPullServerAdminConnection -SQLServer localhost -Credential $sqlCred -Database DSC
Get-DSCPullServerAdminRegistration | Set-DSCPullServerAdminRegistration -ConfigurationNames 'BaseServerConfig'

# pull config