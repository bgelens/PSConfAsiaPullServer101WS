# PSConfASIA Workshop DSC Pull Server 101

This repository contains the files needed to follow along during the Workshop **DSC Pull Server 101**.

## Pre-requisites

To follow along you need 2 VMs on either local Hyper-V or a cloud of your choosing. The VMs need to be able to communicate with each other and with the internet.

VM 1 will be the DSC Pull Server and needs to be installed with Windows Server 2019 (technical preview if RTM is not yet available). It will also need an installation of SQL Server 2017 (at least [Express edition](https://www.microsoft.com/en-us/sql-server/sql-server-editions-express)) which need to be configured in **mixed authentication mode** and it needs to **accept TCP connections**. 

>A script to automate the SQL installation is provided below.

VM 2 will be an LCM client and needs at least Windows Server 2012R2 with WMF5.1 installed. It would be preferred if this VM would be Server 2019 as well. If you don't have the resources, this VM isn't really necessary.

### Hyper-V

If you are hosting the VMs locally on Hyper-V, download the technical preview vhdx by signing up [here](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewserver). If you are using another Hypervisor or virtualization system, download the ISO instead.

Create 2 VMs, each with a copy or fresh installation of Windows Server 2019.

On VM1 run:

```powershell
# disable firewall
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

# download sql 2017 express setup file
$sqlExpressUri = 'https://download.microsoft.com/download/5/E/9/5E9B18CC-8FD5-467E-B5BF-BADE39C51F73/SQLServer2017-SSEI-Expr.exe'
Invoke-WebRequest -Uri $sqlExpressUri -UseBasicParsing -OutFile "$env:TEMP\SQLServer2017-SSEI-Expr.exe"

# write configuration ini
@'
[OPTIONS]
ROLE="AllFeatures_WithDefaults"
ENU="True"
FEATURES=SQLENGINE
INSTANCENAME="MSSQLSERVER"
INSTANCEID="MSSQLSERVER"
SECURITYMODE="SQL"
ADDCURRENTUSERASSQLADMIN="True"
TCPENABLED="1"
SAPWD="Welkom01"
'@ | Out-File -FilePath c:\Configuration.ini -Force

# install sql 2017 (this will take some time!)
Start-Process -FilePath "$env:TEMP\SQLServer2017-SSEI-Expr.exe" -ArgumentList @(
    '/ACTION="Install"'
    '/ConfigurationFile=C:\Configuration.ini',
    '/IAcceptSqlServerLicenseTerms',
    '/LANGUAGE=en-us',
    '/QUIET'
) -Wait

# download demo files
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/bgelens/PSConfAsiaPullServer101WS/archive/master.zip' -OutFile $env:TEMP\master.zip
Expand-Archive -Path $env:TEMP\master.zip -DestinationPath ~\Desktop -Force

# rename computer
if ($env:COMPUTERNAME -ne 'wspull') {
    Rename-Computer -NewName 'wspull' -Force -Restart
}
```

On VM 2 run:

```powershell
# download demo files
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/bgelens/PSConfAsiaPullServer101WS/archive/master.zip' -OutFile $env:TEMP\master.zip
Expand-Archive -Path $env:TEMP\master.zip -DestinationPath ~\Desktop -Force
```

### Azure

If you want to host the VMs on Azure, you can make just [![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbgelens%2FPSConfAsiaPullServer101WS%2Fmaster%2Fdeploy.json)

It will deploy 2 VMs, prepare the Pull Server with the SQL installation and assign a public IP to both VMs.
