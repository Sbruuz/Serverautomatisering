#Define the log file path
$logPath = "C:\Users\sofie\OneDrive - EFIF\ZBC\H3\Serverautomatisering 2\ServerStatusLog.txt"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logPath -Value $logMessage
}

# Try-Catch block to handle errors
try {
    # Get CPU usage
    $cpuUsage = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    Log-Message "CPU Usage: $cpuUsage%"

    # Get RAM status
    $ram = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [math]::round($ram.TotalVisibleMemorySize/1MB, 2)
    $freeRAM = [math]::round($ram.FreePhysicalMemory/1MB, 2)
    $usedRAM = [math]::round($totalRAM - $freeRAM, 2)
    $ramUsage = [math]::round(($usedRAM / $totalRAM) * 100, 2)
    Log-Message "RAM Status: Total: $totalRAM GB, Used: $usedRAM GB, Free: $freeRAM GB, Usage: $ramUsage%"

    # Get Disk status
    $diskStatus = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($disk in $diskStatus) {
        $totalDisk = [math]::round($disk.Size/1GB, 2)
        $freeDisk = [math]::round($disk.FreeSpace/1GB, 2)
        $usedDisk = [math]::round($totalDisk - $freeDisk, 2)
        $diskUsage = [math]::round(($usedDisk / $totalDisk) * 100, 2)
        Log-Message "Disk Status (Drive $($disk.DeviceID)): Total: $totalDisk GB, Used: $usedDisk GB, Free: $freeDisk GB, Usage: $diskUsage%"
    }

    # Get system uptime
    $os = Get-WmiObject Win32_OperatingSystem
    $lastBootUpTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)
    $uptime = (Get-Date) - $lastBootUpTime
    $uptimeFormatted = "$($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds"
    Log-Message "System Uptime: $uptimeFormatted"
}
catch {
    Log-Message "An error occurred: $_"
}

# Output log file path
Write-Host "Log file created at: $logPath" -ForegroundColor Green