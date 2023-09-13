# Get Memory Information
$computerInfo = Get-CimInstance -ClassName CIM_OperatingSystem
$totalMemory = $computerInfo.TotalVisibleMemorySize / 1MB
$freeMemory = $computerInfo.FreePhysicalMemory / 1MB
$usedMemory = $totalMemory - $freeMemory
$memoryUsagePercentage = [math]::Round((($usedMemory / $totalMemory) * 100), 2)
$publicIP = (Invoke-RestMethod -uri "http://ipinfo.io/ip").ToString()
# Get CPU Information
$cpuInfo = Get-CimInstance -ClassName Win32_Processor
$cpuUsagePercentage = [math]::Round(($cpuInfo.LoadPercentage), 2)

# Get Disk Information for each drive
$diskInfos = Get-CimInstance -ClassName Win32_LogicalDisk

# Get Host Name
$hostName = [System.Net.Dns]::GetHostName()

# Get IP Address
$ipAddress = [System.Net.Dns]::GetHostAddresses($hostName) | Where-Object { $_.AddressFamily -eq 'InterNetwork' } | Select-Object -ExpandProperty IPAddressToString

# Get Total Memory in bytes
$totalMemoryBytes = (Get-CimInstance -ClassName CIM_OperatingSystem).TotalVisibleMemorySize * 1024

# Get Total CPU Time
$totalCPUTime = (Get-Process | Measure-Object -Property CPU -Sum).Sum

# Get Top 5 Processes by CPU
$topCPUProcesses = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5 -Property Name, @{Name="CPU(%)";Expression={"{0:N2}" -f (($_.CPU / $totalCPUTime) * 100)}}

# Get Top 5 Processes by Memory
$topMemoryProcesses = Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 5 -Property Name, @{Name="Memory(%)";Expression={"{0:N2}" -f (($_.WS / $totalMemoryBytes) * 100)}}

# Create HTML content
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>System Information</title>
    <style>




    /* New styles for the tables */
    table {
        border-collapse: collapse;
        width: 50%;
        margin: auto
        margin-top: 20px;
        margin-bottom: 20px;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #0000FF;
        color: white;
    }
    tr:nth-child(even) { /* Stripe every other row */
        background-color: #f2f2f2;
    }





        body { font-family: Arial, sans-serif; }
        h1 { color: #333; }
        .info { margin-bottom: 20px; }
        .bar {
            background-color: #f3f3f3;
            border-radius: 13px;
            height: 20px;
            width: 100%;
            padding: 3px;
        }
        .bar span {
            display: block;
            height: 100%;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <h1>System Information</h1>
    <h2>Host: $hostName , Ip address: $ipAddress</h2>
    <h2>public ip:  $publicIP</h2>
    <div class="info">
        <strong>Memory Usage:</strong> $memoryUsagePercentage%
        <div class="bar">
            <span style="width: $memoryUsagePercentage%; background-color: $(if ($memoryUsagePercentage -gt 70) {'red'} else {'green'});"></span>
        </div>
    </div>
    <div class="info">
        <strong>CPU Usage:</strong> $cpuUsagePercentage%
        <div class="bar">
            <span style="width: $cpuUsagePercentage%; background-color: $(if ($cpuUsagePercentage -gt 70) {'red'} else {'green'});"></span>
        </div>
    </div>
"@

foreach ($diskInfo in $diskInfos) {
    $driveLetter = $diskInfo.DeviceID
    $totalDiskSpace = $diskInfo.Size / 1GB
    $freeDiskSpace = $diskInfo.FreeSpace / 1GB
    $usedDiskSpace = $totalDiskSpace - $freeDiskSpace
    $diskUsagePercentage = [math]::Round((($usedDiskSpace / $totalDiskSpace) * 100), 2)

    # Add Disk Usage to HTML content
    $htmlContent += @"
    <div class="info">
        <strong>Disk Usage ($driveLetter):</strong> $diskUsagePercentage%
        <div class="bar">
            <span style="width: $diskUsagePercentage%; background-color: $(if ($diskUsagePercentage -gt 70) {'red'} else {'green'});"></span>
        </div>
    </div>
"@
}

# Add Top CPU Processes to HTML content
$htmlContent += "<h2>Top 5 Processes by CPU Usage:</h2>"
$htmlContent += "<table><tr><th>Name</th><th>CPU Usage (%)</th></tr>"
foreach ($process in $topCPUProcesses) {
    $htmlContent += "<tr><td>$($process.Name)</td><td>$($process.'CPU(%)')</td></tr>"
}
$htmlContent += "</table>"

# Add Top Memory Processes to HTML content
$htmlContent += "<h2>Top 5 Processes by Memory Usage:</h2>"
$htmlContent += "<table><tr><th>Name</th><th>Memory Usage (%)</th></tr>"
foreach ($process in $topMemoryProcesses) {
    $htmlContent += "<tr><td>$($process.Name)</td><td>$($process.'Memory(%)')</td></tr>"
}
$htmlContent += "</table>"

$htmlContent += @"
</body>
</html>
"@

# Write HTML content to a file
$htmlContent | Out-File -FilePath "info.html"
