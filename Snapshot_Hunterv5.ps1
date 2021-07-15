function Snapshot-hunter{
Try{
Connect-VIServer $vcenter -ErrorAction Stop
}
catch {
$ErrorMessage = $_.Exception.Message
Write-Host "Alert!!!! Connection to vCenter failed: $ErrorMessage" -ForegroundColor Red -BackgroundColor Yellow
pause
Write-Host "Please Restart the script" -ForegroundColor Red
start-sleep -Seconds 5
break
} 
$Report="C:\temp\snapshot_report.txt"
$String="*" * 16
Write-host "Checking if existing snapshot report is present...loading" -ForegroundColor Cyan -BackgroundColor Black
if (Test-Path -Path "C:\temp\snapshot_report.txt") {
Write-Host "!!Snapshot Report already present" -ForegroundColor Red -BackgroundColor Yellow
Invoke-Item "C:\temp"
Write-Host "Please delete or archive - C:\temp\snapshot_report.txt" -ForegroundColor Red -BackgroundColor Yellow
pause
temp-cleaner
}
else {
Write-host "Select datastore you want to inspect...loading" -ForegroundColor Cyan -BackgroundColor Black
Start-Sleep -Seconds 5
if (Test-Path -Path "C:\temp") {Write-Host "Snapshot Report folder present" -ForegroundColor Green
Write-Output  $String | Out-File -FilePath $Report
Write-Output "Snapshot Report" | Out-File -FilePath $Report -Append
Write-Output  $String | Out-File -FilePath $Report -Append
}
else {New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
Write-Output  $String | Out-File -FilePath $Report
Write-Output "Snapshot Report" | Out-File -FilePath $Report -Append
Write-Output  $String | Out-File -FilePath $Report -Append
write-host "Report Folder Created - C:\temp" -ForegroundColor Red -BackgroundColor Yellow
Start-Sleep -Seconds 3
}
$targetDS=Get-Datastore | Out-GridView -PassThru
get-datastore -Name $targetDS | Get-VM | Get-Snapshot | select-object -Property VM,Name,Created,Description,IsCurrent,@{ n="SizeGB"; e={[math]::round( $_.SizeGB, 3 )}} | Out-File -FilePath $Report -Append
Invoke-item $Report
Disconnect-VIServer -Server $vcenter -Confirm:$false
Write-Host "Thanks for using Snapshot Hunter! Bye" -ForegroundColor Red -BackgroundColor White
pause
}}
function temp-cleaner{
$Report="C:\temp\snapshot_report.txt"
$String="*" * 16
Write-host "Select datastore you want to inspect...loading" -ForegroundColor Cyan -BackgroundColor Black
Start-Sleep -Seconds 5
if (Test-Path -Path "C:\temp") {Write-Host "Snapshot Report folder present" -ForegroundColor Green
Write-Output  $String | Out-File -FilePath $Report
Write-Output "Snapshot Report" | Out-File -FilePath $Report -Append
Write-Output  $String | Out-File -FilePath $Report -Append
}
else {New-Item -Path "C:\Temp" -ItemType Directory | Out-Null
Write-Output  $String | Out-File -FilePath $Report
Write-Output "Snapshot Report" | Out-File -FilePath $Report -Append
Write-Output  $String | Out-File -FilePath $Report -Append
write-host "Report Folder Created - C:\temp" -ForegroundColor Red -BackgroundColor Yellow
Start-Sleep -Seconds 3
}
$targetDS=Get-Datastore | Out-GridView -PassThru
get-datastore -Name $targetDS | Get-VM | Get-Snapshot | select-object -Property VM,Name,Created,Description,IsCurrent,@{ n="SizeGB"; e={[math]::round( $_.SizeGB, 3 )}} | Out-File -FilePath $Report -Append
Invoke-item $Report
Disconnect-VIServer -Server $vcenter -Confirm:$false
Write-Host "Thanks for using Snapshot Hunter! Bye" -ForegroundColor Red -BackgroundColor White
pause
}

Write-host "Welcome in Snapshot Hunter - Identify & report VM snapshot" -ForegroundColor DarkGreen -BackgroundColor White
pause

DO
{$vcenter=Read-host "Please type the FQDN of the vCenter you want to connect to"
$confirmation=Read-host "Please confirm that you want to connect to $vcenter y/n"
}
until ($confirmation -eq "y")
Snapshot-hunter


<#
.SYNOPSIS
---------
This tool is designed to identify quickly the presence of snapshots on a datastore running low of free space.

.DESCRIPTION
------------
This script has been written with the objective of quickly investigate space issue on datastores.
It eleminates or confirms the presence of snapshots on the concerned datastore. Mostly in big environments, forgotten snapshots are often the root cause of room issue on DS.
If presence of snapshots is confirmed, the user of the script will receive a report of the supicious datastore in text format with the following information:
*VM impacted
*Creation date of the snapshot
*Description of the snapshot if it has been specified when created
*If the identified snapshot is the most recent of chain
*The size of the snapshot

This script is designed as follow
Part 1. A function is created to launch the report about the specific datastores you want to analyze
Part 2. A second function is created to launch the report about the specific datastores you want to analyze after checking the content of the local report folder
Part 3. A loop that permits to manage user inputs errors when the vcenter name is not the expected one. Ex: User is aware of a typo error
Part 4. A call of the first function is realized to create the report 

This script has no impact on vSphere environment as it retreives data only ( no modification on the infrastructure)

.INPUTS
-------
1. Vcenter you want to connect to
2. Your VC account credentials if they are not stored locally
3. Datastore name you want to inspect. input is done via Outgrid-view function which prevents typo issues (multiple DS can be selected)

.OUTPUTS
--------
The output of the script is the creation of a text file in the following location "C:\Temp". 
The script will create the folder to store the report if it doesn't exist
The name of the file is: snapshot_report.txt

For each snapshot found, the report will throw the following information:
VM Name (concerned VM)
Creation date of the snapshot
Description (if completed)
Verification if the found snapshot is the current one or if is member of a chain
Size of the Snapshot expressed in GB (max 3 figures after the comma - ex SizeGB : 1,337 --> 1GB and 337 MB / I mention it as your locale settings can give you others results)


.NOTES
------

*VERSION

Current version is v1.0 (15/07/2021)

*PREREQUISITE

PowerCLI module 6.5 minimum present on your machine where you run the tool

*LIMITATION

The machine where will be run the script must be a Windows machine as a report will be created in the following folder:
C:\temp

*AUTHOR

Michaël Militoni
#>
