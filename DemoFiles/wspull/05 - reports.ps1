# first show reporting through api
$agentId = '2DB19967-BB6A-11E8-A340-00155D00692E' #TODO: UPDATE :|
$uri = "http://localhost:8080/PSDSCPullServer.svc/Nodes(AgentId = '$agentId')"

$irmArgs = @{
    Headers = @{
        Accept = 'application/json'
        ProtocolVersion = '2.0'
    }
    UseBasicParsing = $true
}

$node = Invoke-RestMethod @irmArgs -Uri $uri
$node

$uri = "http://localhost:8080/PSDSCPullServer.svc/Nodes(AgentId = '$agentId')/Reports"
$reports = Invoke-RestMethod @irmArgs -Uri $uri
$reports.value

# now via SQL
# install dscpullserveradmin
Install-Module -Name DSCPullServerAdmin -Scope CurrentUser -Force
Get-Command -Module DSCPullServerAdmin

# connect with db and enumerate
$sqlCred = [pscredential]::new('sa', (ConvertTo-SecureString 'Welkom01' -AsPlainText -Force))
New-DSCPullServerAdminConnection -SQLServer localhost -Credential $sqlCred -Database DSC

# get node object from db
Get-DSCPullServerAdminRegistration

# get reports from db
Get-DSCPullServerAdminStatusReport -OutVariable reports
$reports[0]
$reports.Where{$_.operationtype -eq 'initial'}.statusdata | select resource* | ConvertTo-Json
