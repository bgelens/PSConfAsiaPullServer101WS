# stage module
tree /A C:\Users\Administrator\Documents\WindowsPowerShell\Modules\ComputerManagementDsc

# modules distributed by pull server must be zipped but have special requirement
$version = (Get-Module ComputerManagementDsc -ListAvailable).Version.ToString()
Compress-Archive -Path C:\Users\Administrator\Documents\WindowsPowerShell\Modules\ComputerManagementDsc\$version\* -DestinationPath C:\pullserver\Modules\ComputerManagementDsc_$version.zip -Force

New-DscChecksum -Path C:\pullserver\Modules\ComputerManagementDsc_$version.zip  -Force

# pull again