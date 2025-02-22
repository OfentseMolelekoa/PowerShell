# Define the time for the restart (24-hour format)
$restartTime = "02:00"  # Example: 2 AM

# Get the current time
$currentTime = Get-Date -Format "HH:mm"

# Calculate the difference in time between now and the scheduled time
$timeToWait = [datetime]::ParseExact($restartTime, "HH:mm", $null) - [datetime]::ParseExact($currentTime, "HH:mm", $null)

# If the scheduled time has already passed today, add 24 hours to schedule it for tomorrow
if ($timeToWait.TotalSeconds -lt 0) {
    $timeToWait = $timeToWait.AddDays(1)
}

# Wait until the scheduled time
Write-Host "Server will restart at $restartTime. Waiting for $($timeToWait.TotalMinutes) minutes..."
Start-Sleep -Seconds $timeToWait.TotalSeconds

# Ensure SQL Server service is running
$SQLService = Get-Service -Name 'MSSQLSERVER' # Default SQL Server service name
if ($SQLService.Status -ne 'Running') {
    Write-Host "SQL Server is not running. Starting SQL Server service..."
    Start-Service -Name 'MSSQLSERVER'
} else {
    Write-Host "SQL Server is already running."
}

# Ensure Remote Desktop service (RDP) is running
$RDPService = Get-Service -Name 'TermService' # Remote Desktop service
if ($RDPService.Status -ne 'Running') {
    Write-Host "RDP is not running. Starting Remote Desktop service..."
    Start-Service -Name 'TermService'
} else {
    Write-Host "RDP is already running."
}

# Restart the server
Write-Host "Restarting the server now..."
Restart-Computer -Force
