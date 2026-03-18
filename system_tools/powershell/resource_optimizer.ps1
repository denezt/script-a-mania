# ---------------------------------------------------------
# Activity Keeper with Monitoring
# Sends keepalive state key periodically to prevent idle status
# ---------------------------------------------------------

# Configuration
$IntervalSeconds = 120          # Time between key sends
$KeyToSend = "{F15}"            # Safe unused key
$ScriptStart = Get-Date
$ActivityCount = 0

# Create WScript Shell
$WshShell = New-Object -ComObject WScript.Shell

# Display header
Clear-Host
Write-Host "========================================="
Write-Host " Teams Activity Keeper Monitor"
Write-Host "========================================="
Write-Host "Start Time      : $ScriptStart"
Write-Host "Interval (sec)  : $IntervalSeconds"
Write-Host "Press CTRL + C to stop"
Write-Host "========================================="
Write-Host ""

while ($true) {

    try {

        # Send the key
        $WshShell.SendKeys($KeyToSend)

        # Update counters
        $ActivityCount++
        $Now = Get-Date
        $Elapsed = New-TimeSpan -Start $ScriptStart -End $Now

        # Console monitoring output
        Write-Host "----------------------------------------"
        Write-Host "Current Time     : $($Now.ToString("yyyy-MM-dd HH:mm:ss"))"
        Write-Host "Activity Sent    : $ActivityCount"
        Write-Host "Elapsed Runtime  : $($Elapsed.ToString())"
        Write-Host "Next Activity In : $IntervalSeconds seconds"
        Write-Host "----------------------------------------"

        # Wait before next action
        Start-Sleep -Seconds $IntervalSeconds
    }
    catch {
        Write-Host "Error occurred: $_"
    }
}