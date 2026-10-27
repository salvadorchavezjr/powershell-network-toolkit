
# ==========================================
# MSSA Project 2
# Network Troubleshooting Toolkit
# Version 3.0
# ==========================================

# FUNCTION 1: Display Main Menu
function Show-Menu {
    Clear-Host

    Write-Host "====================================" -ForegroundColor Cyan
    Write-Host "    NETWORK TROUBLESHOOTING TOOL     " -ForegroundColor Cyan
    Write-Host "====================================" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "1. Display IP Configuration"
    Write-Host "2. Test Network Connectivity"
    Write-Host "3. Test DNS Resolution"
    Write-Host "4. Test TCP Ports"
    Write-Host "5. Display Network Adapters"
    Write-Host "6. Generate Network Report"
    Write-Host "7. Exit"
    Write-Host ""
}

# FUNCTION 2: Display IP Configuration
function Show-IPConfiguration {
    Write-Host "`n=== IP CONFIGURATION ===" -ForegroundColor Yellow

    Get-NetIPConfiguration |
        Format-Table InterfaceAlias, IPv4Address, IPv4DefaultGateway -AutoSize
}

# FUNCTION 3: Test Network Connectivity
function Test-NetworkConnectivity {
    Write-Host "`n=== NETWORK CONNECTIVITY TEST ===" -ForegroundColor Yellow

    $Target = Read-Host "Enter an IP address or hostname"

    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Please enter a valid target." -ForegroundColor Red
        return
    }

    try {
        Write-Host "Testing connection to $Target..." -ForegroundColor Cyan

        Test-Connection -ComputerName $Target -Count 4 -ErrorAction Stop
    }
    catch {
        Write-Host "Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 4: Test DNS Resolution
function Test-DNSResolution {
    Write-Host "`n=== DNS RESOLUTION TEST ===" -ForegroundColor Yellow

    $Domain = Read-Host "Enter a domain name"

    if ([string]::IsNullOrWhiteSpace($Domain)) {
        Write-Host "Please enter a domain name." -ForegroundColor Red
        return
    }

    try {
        Resolve-DnsName -Name $Domain -ErrorAction Stop |
            Where-Object { $_.Type -in @("A", "AAAA") } |
            Select-Object Name, Type, IPAddress |
            Format-Table -AutoSize
    }
    catch {
        Write-Host "DNS lookup failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 5: Test TCP Port
function Test-TCPPort {
    Write-Host "`n=== TCP PORT TEST ===" -ForegroundColor Yellow

    $Target = Read-Host "Enter hostname or IP address"
    $PortInput = Read-Host "Enter TCP port number (1-65535)"

    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Please enter a hostname or IP." -ForegroundColor Red
        return
    }

    $Port = 0

    if (-not [int]::TryParse($PortInput, [ref]$Port) -or
        $Port -lt 1 -or $Port -gt 65535) {
        Write-Host "Invalid port number." -ForegroundColor Red
        return
    }

    try {
        $Result = Test-NetConnection `
            -ComputerName $Target `
            -Port $Port `
            -WarningAction SilentlyContinue `
            -ErrorAction Stop

        if ($Result.TcpTestSucceeded) {
            Write-Host "SUCCESS: $Target TCP port $Port is reachable" -ForegroundColor Green
        }
        else {
            Write-Host "FAILED: TCP port $Port could not be reached" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Port test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 6: Display Network Adapters
function Show-NetworkAdapters {
    Write-Host "`n=== NETWORK ADAPTER INFORMATION ===" -ForegroundColor Yellow

    try {
        Get-NetAdapter -ErrorAction Stop |
            Select-Object Name, InterfaceDescription,
                Status, MacAddress, LinkSpeed |
            Format-Table -AutoSize
    }
    catch {
        Write-Host "Unable to retrieve adapters: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 7: Generate Network Report
function Export-NetworkReport {
    Write-Host "`n=== GENERATING NETWORK REPORT ===" -ForegroundColor Yellow

    try {
        # Create Reports folder if it does not exist
        $ReportFolder = Join-Path $PSScriptRoot "Reports"

        if (-not (Test-Path $ReportFolder)) {
            New-Item -ItemType Directory -Path $ReportFolder -ErrorAction Stop |
                Out-Null
        }

        # Collect network configuration
        $Configurations = Get-NetIPConfiguration -ErrorAction Stop
        $Report = foreach ($Config in $Configurations) {

            $Adapter = Get-NetAdapter `
                -InterfaceIndex $Config.InterfaceIndex `
                -ErrorAction SilentlyContinue

            [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Interface = $Config.InterfaceAlias
                Status = if ($Adapter) { $Adapter.Status } else { "Unknown" }
                IPv4Address = ($Config.IPv4Address.IPAddress -join ", ")
                Gateway = ($Config.IPv4DefaultGateway.NextHop -join ", ")
                DNSServers = ($Config.DNSServer.ServerAddresses -join ", ")
                MACAddress = if ($Adapter) { $Adapter.MacAddress } else { "" }
            }
        }

        # Create timestamped CSV file
        $FileName = "NetworkReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        $ReportPath = Join-Path $ReportFolder $FileName

        $Report | Export-Csv -Path $ReportPath -NoTypeInformation -ErrorAction Stop

        Write-Host "Report generated successfully!" -ForegroundColor Green
        Write-Host "Saved to: $ReportPath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "Report generation failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# MAIN APPLICATION LOOP
do {
    Show-Menu

    $Choice = Read-Host "Enter your selection (1-7)"

    switch ($Choice) {
        "1" { Show-IPConfiguration }
        "2" { Test-NetworkConnectivity }
        "3" { Test-DNSResolution }
        "4" { Test-TCPPort }
        "5" { Show-NetworkAdapters }
        "6" { Export-NetworkReport }
        "7" {
            Write-Host "Exiting Network Toolkit..." -ForegroundColor Green
        }
        default {
            Write-Host "Invalid selection. Choose 1-7." -ForegroundColor Red
        }
    }

    if ($Choice -ne "7") {
        Write-Host ""
        Read-Host "Press Enter to return to the main menu"
    }

} while ($Choice -ne "7")
