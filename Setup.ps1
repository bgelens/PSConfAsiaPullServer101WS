param (
    [switch] $CopyDemoOnly,

    [string] $UserName,

    [string] $Password
)

# disable servermanager
$null = Get-ScheduledTask -TaskName servermanager | Disable-ScheduledTask

# setup vs code and install ps extension
Enable-PSRemoting -Force -SkipNetworkProfileCheck
$userCred = [pscredential]::new(".\$UserName", (ConvertTo-SecureString -String $Password -AsPlainText -Force))
Invoke-Command -Credential $userCred -ScriptBlock {
    Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?Linkid=852157 -OutFile $env:TEMP\vscode-stable.exe
    Start-Process -Wait $env:TEMP\vscode-stable.exe -ArgumentList /silent, /mergetasks=!runcode
    Start-Process -Wait 'C:\Program Files\Microsoft VS Code\bin\code.cmd' -ArgumentList '--install-extension "ms-vscode.PowerShell"'
}

# download demo files
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/bgelens/PSConfAsiaPullServer101WS/archive/master.zip' -OutFile $env:TEMP\master.zip
Expand-Archive -Path $env:TEMP\master.zip -DestinationPath c:\Users\Public\Desktop -Force

# disable firewall
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

if ($CopyDemoOnly) {
    return
}

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

# download setupfiles
Start-Process -FilePath "$env:TEMP\SQLServer2017-SSEI-Expr.exe" -ArgumentList @(
    '/Action=Download',
    '/Quiet',
    '/MEDIAPATH=c:\Windows\TEMP'
) -Wait

# extract setupfiles
Start-Process -FilePath "C:\Windows\Temp\sqlexpr_x64_enu.exe" -ArgumentList @(
    '/x:c:\setup /q'
) -Wait
 
# install sql 2017 (this will take some time!)
Start-Process -FilePath "c:\setup\setup.exe" -ArgumentList @(
    '/ACTION="Install"'
    '/ConfigurationFile=C:\Configuration.ini',
    '/IAcceptSqlServerLicenseTerms',
    '/QUIET'
) -Wait


