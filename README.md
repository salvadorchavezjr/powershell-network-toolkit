# PowerShell Network Troubleshooting Toolkit

An interactive Windows network troubleshooting application developed using PowerShell as part of my Microsoft Software & Systems Academy (MSSA) Server & Cloud Administration training.

## Project Overview

The Network Troubleshooting Toolkit is a PowerShell application designed to simplify common network diagnostic tasks through an interactive command-line menu.

Rather than manually entering different PowerShell commands, users can select a troubleshooting option to retrieve network information, test connectivity, diagnose DNS issues, and generate reports.

This project demonstrates fundamental networking concepts, PowerShell scripting, and IT troubleshooting techniques.

## Features

### 1. Display IP Configuration
Retrieves network configuration information, including:
- Network interface names
- IPv4 addresses
- Default gateways

**PowerShell command:** `Get-NetIPConfiguration`

### 2. Test Network Connectivity
Allows users to enter an IP address or hostname and perform four ICMP ping requests to test connectivity.

**PowerShell command:** `Test-Connection`

### 3. Test DNS Resolution
Allows users to enter a domain name and retrieve its IPv4 (A) and IPv6 (AAAA) DNS records.

**PowerShell command:** `Resolve-DnsName`

### 4. Test TCP Port Connectivity
Tests whether a specified TCP port is reachable on a target computer or server.

Common examples:
- Port 80 — HTTP
- Port 443 — HTTPS
- Port 53 — DNS over TCP
- Port 3389 — Remote Desktop

**PowerShell command:** `Test-NetConnection`

### 5. Display Network Adapters
Displays network adapter information, including:
- Adapter name
- Interface description
- Connection status
- MAC address
- Link speed

**PowerShell command:** `Get-NetAdapter`

### 6. Generate Network Report
Automatically collects network configuration information and exports the results to a timestamped CSV file.

Reports include:
- Computer name
- Date and time
- Network interface
- Connection status
- IPv4 address
- Default gateway
- DNS servers
- MAC address

**PowerShell command:** `Export-Csv`

## Technologies Used

- Windows PowerShell
- Visual Studio Code
- Git and GitHub
- TCP/IP networking
- DNS
- Windows network management cmdlets
- CSV reporting

## How to Run

**Requirements:**
- Windows 10 or Windows 11
- Windows PowerShell 5.1 with the required Windows networking modules available
- Permission to execute the script under your organization's security policies

**Instructions:**

1. Clone or download this repository.
2. Open the project folder in Visual Studio Code.
3. Open a PowerShell terminal.
4. Run:

```powershell
.\NetworkToolkit.ps1
```

5. Select a menu option from 1–7.
6. Follow the prompts to perform a network diagnostic test.
7. Select option