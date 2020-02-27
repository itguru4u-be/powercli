Clear-Variable Customer* -Scope Global
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
[System.Windows.MessageBox]::Show('ATTENTION!!! you are about to backup ESXI host configuration','Warning')
$CustomerCentralRepoPath = [Microsoft.VisualBasic.Interaction]::InputBox("Enter path of the central backup Repository for ESXI", "Repository", "\\eu1psfas1\Install_source\Backup ESXI config")
if (Test-Path "$CustomerCentralRepoPath"){
Add-Type -AssemblyName PresentationFramework | Out-Null
[System.Windows.MessageBox]::Show('Central Repository already exist! Backup process will continue!!!','Information')}
else{
New-Item -path "$CustomerCentralRepoPath" -type directory}
$CustomerVC = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a vCenter name", "vCenter", "$env:computername")
$CustomerCluster = [Microsoft.VisualBasic.Interaction]::InputBox("Enter a Cluster name", "Cluster")
$CustomerHosts = Get-VMhost -Location "$CustomerCluster"
$CustomerESXIclusterUPath = [Microsoft.VisualBasic.Interaction]::InputBox("Enter path of the unique backup Repository for ESXI", "Repository", "$CustomerCentralRepoPath\$CustomerCluster-$(Get-Date -Format ddMMyyyy)")
if (Test-Path "$CustomerESXIclusterUPath"){
Add-Type -AssemblyName PresentationFramework | Out-Null
[System.Windows.MessageBox]::Show('Cluster Repository already exist! Backup process will abort!!!','Warning')
exit}
else{
New-Item -path "$CustomerESXIclusterUPath" -type directory}
Connect-VIServer "$CustomerVC"
Get-VMhost -Location "$CustomerCluster" | Select-Object -Property Name, Manufacturer, Model, Version, Build |Format-Table |Out-File -FilePath "$CustomerCentralRepoPath\$CustomerCluster-$(Get-Date -Format ddMMyyyy)\backupesxi.txt"
Get-VMHostFirmware -VMHost $CustomerHosts -BackupConfiguration -DestinationPath "$CustomerESXIclusterUPath"
