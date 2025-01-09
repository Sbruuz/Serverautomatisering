<#
.SYNOPSIS
Logs system status information (OS, RAM, CPU, Disk, Uptime) to a log file and displays it.

.DESCRIPTION
This script detects the operating system (Windows or Linux), logs and displays the following information. 
- Operating System
- Total, Used, and Free RAM
- CPU usage
- Total, Used, and Free Disk Space
- System Uptime
It writes the logs to a specified file (depending on the OS) and outputs key information to the console.

.PARAMETER Message
The message to log to the specified log file.

.EXAMPLE
PS C:\> ./SystemInfo.ps1
This runs the script to detect the OS and log system status information to a file.

PS C:\> ./SystemInfo.ps1
Logs information like CPU usage, disk space, memory status, and uptime based on the detected OS.

.NOTES
Author: Sofie Ruus
Version: 1.0
Date: 07-01-2025
#>

#Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("dd-MM-yyyy HH:mm:ss")
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $logEntry
    Write-Output $logEntry
}

#OS Detection
if ($env:OS -eq "Windows_NT") {
    $OSVersion = "Windows"
    $LogFilePath = "C:\temp\StatusLog.log"
} elseif ($env:TERM -eq "Linux") {
    $OSVersion = "Linux"
    $LogFilePath = "/tmp/StatusLog.log"
} else {
    $OSVersion = "Unknown"
}

#Log the detected OS
Log-Message "Operating System Detected: $OSVersion."

#Get RAM status based on OS
if ($OSVersion -eq "Windows") {
    $ram = Get-WmiObject Win32_OperatingSystem
    $totalRAM = [math]::round($ram.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::round($ram.FreePhysicalMemory / 1MB, 2)
    $usedRAM = [math]::round($totalRAM - $freeRAM, 2)
    Log-Message "RAM Status (Windows): Total: $totalRAM GB, Used: $usedRAM GB, Free: $freeRAM GB"
} elseif ($OSVersion -eq "Linux") {
    $ramInfo = Get-Content /proc/meminfo
    $totalRAM = ($ramInfo | Select-String "MemTotal" | ForEach-Object { ($_ -split "\s+")[1] }) -as [int]
    $freeRAM = ($ramInfo | Select-String "MemFree" | ForEach-Object { ($_ -split "\s+")[1] }) -as [int]
    $usedRAM = $totalRAM - $freeRAM
    $totalRAMGB = [math]::round($totalRAM / 1024, 2)
    $usedRAMGB = [math]::round($usedRAM / 1024, 2)
    Log-Message "RAM Status (Linux): Total: $totalRAMGB MB, Used: $usedRAMGB MB, Free: $([math]::round($freeRAM / 1024, 2)) MB"
} else {
    Log-Message "Unable to retrieve RAM status: Unknown Operating System."
}

#Get CPU usage based on OS
if ($OSVersion -eq "Windows") {
    $cpu = Get-WmiObject Win32_Processor
    $cpuUsage = [math]::round(($cpu.LoadPercentage), 2)
    Log-Message "CPU Usage (Windows): $cpuUsage%"
} elseif ($OSVersion -eq "Linux") {
    $cpuUsage = (top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    Log-Message "CPU Usage (Linux): $cpuUsage%"
} else {
    Log-Message "Unable to retrieve CPU usage: Unknown Operating System."
}

#Get Disk status based on OS
if ($OSVersion -eq "Windows") {
    $disk = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($d in $disk) {
        $totalDisk = [math]::round($d.Size / 1GB, 2)
        $freeDisk = [math]::round($d.FreeSpace / 1GB, 2)
        $usedDisk = [math]::round($totalDisk - $freeDisk, 2)
        Log-Message "Disk Status (Windows): Drive $($d.DeviceID): Total: $totalDisk GB, Used: $usedDisk GB, Free: $freeDisk GB"
    }
} elseif ($OSVersion -eq "Linux") {
    $diskInfo = df -h /
    $diskInfo | ForEach-Object {
        if ($_ -match "^/") {
            $totalDisk = [math]::round(($_ -split "\s+")[1] -replace "G", "")
            $usedDisk = [math]::round(($_ -split "\s+")[2] -replace "G", "")
            $freeDisk = [math]::round(($_ -split "\s+")[3] -replace "G", "")
            Log-Message "Disk Status (Linux): Total: $totalDisk GB, Used: $usedDisk GB, Free: $freeDisk GB"
        }
    }
} else {
    Log-Message "Unable to retrieve disk status: Unknown Operating System."
}

#Get Uptime based on OS
if ($OSVersion -eq "Windows") {
    $uptime = (Get-WmiObject Win32_OperatingSystem).ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)
    $uptimeFormatted = (New-TimeSpan -Start $uptime -End (Get-Date))
    Log-Message "System Uptime (Windows): $($uptimeFormatted.Days) Days, $($uptimeFormatted.Hours) Hours, $($uptimeFormatted.Minutes) Minutes"
} elseif ($OSVersion -eq "Linux") {
    $uptime = (uptime -p)
    Log-Message "System Uptime (Linux): $uptime"
} else {
    Log-Message "Unable to retrieve system uptime: Unknown Operating System."
}