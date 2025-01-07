#Function to log messages
function Log-Message {
    param (
        [string]$Message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LogFilePath -Value $logEntry
    Write-Output $logEntry
}

#OS Detection
if ($env:OS -eq "Windows_NT") {
    $OSVersion = "Windows"
    $LogFilePath = "C:\temp\StatusLog.log"
} elseif (Test-Path "/tmp/") {
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
    $totalRAM = ($ramInfo | Select-String "MemTotal" | ForEach-Object { ($ -split "\s+")[1] }) -as [int]
    $freeRAM = ($ramInfo | Select-String "MemFree" | ForEach-Object { ($ -split "\s+")[1] }) -as [int]
    $usedRAM = $totalRAM - $freeRAM
    $totalRAMGB = [math]::round($totalRAM / 1024, 2)
    $usedRAMGB = [math]::round($usedRAM / 1024, 2)
    Log-Message "RAM Status (Linux): Total: $totalRAMGB GB, Used: $usedRAMGB GB, Free: $([math]::round($freeRAM / 1024, 2)) GB"
} else {
    Log-Message "Unable to retrieve RAM status: Unknown Operating System."
}