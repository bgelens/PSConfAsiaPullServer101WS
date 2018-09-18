#check if sql is listening
Test-NetConnection -ComputerName localhost -Port 1433 -InformationLevel Quiet

#if not
ii C:\Windows\SysWOW64\SQLServerManager14.msc
# SQL Server Network Configuration -> Protocols for MSSQLSERVER -> TCP/IP enable
Restart-Service -Name MSSQLSERVER -Force

# test again

# is computername set?
$env:COMPUTERNAME -eq 'wspull'

# is firewall disabled?
Get-NetFirewallProfile | % enabled
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False