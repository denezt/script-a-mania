


$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File .\resource_optimizer.ps1"
$Trigger = New-ScheduledTaskTrigger -AtLogOn

Register-ScheduledTask -TaskName "ResourceOptimizer" -Action $Action -Trigger $Trigger -Description "Keeps system activity alive, and prevents idle status by sending a key press every 4 minutes." -User "SYSTEM" -RunLevel Highest