
# ==========================================
# MSSA Project 2
# Network Troubleshooting Toolkit
# Version 2.0
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
    Write-Host "5. Display Network Adapters (Coming Soon)"
    Write-Host "6. Generate Network Report (Coming Soon)"
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

    $Target = Read-Host "Enter an IP address or hostname (example: 8.8.8.8)"

    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "Please enter a valid target." -ForegroundColor Red
        return
    }

    Write-Host "`nTesting connection to $Target..." -ForegroundColor Cyan

    try {
        Test-Connection -ComputerName $Target -Count 4 -ErrorAction Stop
    }
    catch {
        Write-Host "Connection test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 4: Test DNS Resolution
function Test-DNSResolution {

    Write-Host "`n=== DNS RESOLUTION TEST ===" -ForegroundColor Yellow

    $Domain = Read-Host "Enter a domain name (example: google.com)"

    if ([string]::IsNullOrWhiteSpace($Domain)) {
        Write-Host "Please enter a domain name." -ForegroundColor Red
        return
    }

    try {
        Write-Host "`nResolving $Domain..." -ForegroundColor Cyan

        Resolve-DnsName -Name $Domain -ErrorAction Stop |
            Where-Object { $_.Type -in @("A", "AAAA") } |
            Select-Object Name, Type, IPAddress |
            Format-Table -AutoSize
    }
    catch {
        Write-Host "DNS lookup failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# FUNCTION 5: Test TCP Port Connectivity
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
            Write-Host "SUCCESS: $Target is reachable on TCP port $Port" -ForegroundColor Green
        }
        else {
            Write-Host "FAILED: TCP port $Port could not be reached on $Target" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Port test error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# MAIN APPLICATION LOOP
do {

    Show-Menu

    $Choice = Read-Host "Enter your selection (1-7)"

    switch ($Choice) {

        "1" {
            Show-IPConfiguration
        }

        "2" {
            Test-NetworkConnectivity
        }

        "3" {
            Test-DNSResolution
        }

        "4" {
            Test-TCPPort
        }

        "7" {
            Write-Host "Exiting Network Toolkit..." -ForegroundColor Green
        }

        default {
            Write-Host "Option unavailable. Please select 1-4 or 7." -ForegroundColor Red
        }
    }

    if ($Choice -ne "7") {
        Write-Host ""
        Read-Host "Press Enter to return to the main menu"
    }

} while ($Choice -ne "7")
