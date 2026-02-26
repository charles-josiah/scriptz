<#
README (Quick)
==============
Title: Local User Audit for Windows Servers (AD OU or CSV Input) + Port Triage (RDP/SSH)

What it does:
- Builds a target server list from either:
  1) An Active Directory OU (Get-ADComputer), or
  2) A CSV file you provide.
- For each server:
  - Tests TCP/3389 (RDP).
    - If 3389 is open, tests WinRM (Test-WSMan).
      - If WinRM is OK, collects local users via Get-LocalUser (Invoke-Command).
      - If WinRM fails, logs the reason.
  - If 3389 is NOT open, tests TCP/22 (SSH).
    - If 22 is open, logs "Likely Linux host" (no WinRM attempt).
    - If 22 is NOT open, logs "No response on 3389 and 22".
- Exports:
  - A CSV report with local users (Windows hosts successfully queried)
  - A CSV triage/errors report (unreachable, likely Linux, WinRM issues, etc.)
- Prints a final summary with counters and duration.

Requirements:
- PowerShell 5.1+ recommended.
- If using AD OU input: RSAT / ActiveDirectory module (Get-ADComputer).
- WinRM enabled on target Windows servers and network access to TCP/5985 or 5986.

Usage:
- Edit the CONFIG section below (OU DN, paths).
- Run the entire script (do not run only the loop selection), otherwise credential variables may be null.
#>

# -------------------------
# CONFIG
# -------------------------

# Choose ONE input mode:
$UseAD_OrganizationalUnit = $true     # $true = use AD OU; $false = use CSV input

# AD OU DN (placeholder)
$AD_OrganizationalUnitDN = "OU=Servers,DC=example,DC=local"

# CSV input (placeholder)
$InputCsvPath  = "C:\Temp\Hosts_Input.csv"      # Expected columns (example): Server;Status
$InputCsvDelimiter = ";"

# Output paths
$OutputUsersCsvPath  = "C:\Temp\Local_Users_Report.csv"
$OutputTriageCsvPath = "C:\Temp\Hosts_Triage_Report.csv"

# Working dir
$WorkDir = "C:\Temp"

# Timeouts (ms)
$TcpTimeoutMs = 1500

# -------------------------
# PREP
# -------------------------

if (!(Test-Path $WorkDir)) {
    New-Item -Path $WorkDir -ItemType Directory | Out-Null
}

# Get credential ONCE and reuse
if (-not $Cred -or -not ($Cred -is [System.Management.Automation.PSCredential])) {
    $Cred = Get-Credential -Message "Enter credentials for remote execution (WinRM)."
}

function Test-TcpPort {
    param(
        [Parameter(Mandatory=$true)][string]$ComputerName,
        [Parameter(Mandatory=$true)][int]$Port,
        [int]$TimeoutMs = 1500
    )

    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect($ComputerName, $Port, $null, $null)
        $ok = $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)
        if (-not $ok) { $client.Close(); return $false }
        $client.EndConnect($iar) | Out-Null
        $client.Close()
        return $true
    } catch {
        try { $client.Close() } catch {}
        return $false
    }
}

# -------------------------
# INPUT: Servers list
# -------------------------

$Computers = @()

if ($UseAD_OrganizationalUnit) {
    # Requires ActiveDirectory module (RSAT)
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    } catch {
        throw "ActiveDirectory module not available. Install RSAT or switch to CSV input mode."
    }

    $Computers = Get-ADComputer -SearchBase $AD_OrganizationalUnitDN -Filter * |
                 Select-Object -ExpandProperty Name
}
else {
    if (!(Test-Path $InputCsvPath)) {
        throw "Input CSV not found: $InputCsvPath"
    }

    # Example CSV:
    # Server;Status
    # srv01;ok
    # srv02;down
    $data = Import-Csv -Path $InputCsvPath -Delimiter $InputCsvDelimiter
    $Computers = $data.Server | Where-Object { $_ -and $_.Trim() -ne "" }
}

$TotalHosts = $Computers.Count

# -------------------------
# Counters + logging arrays
# -------------------------

$Count_Success              = 0
$Count_RDP_Down             = 0
$Count_SSH_Open_LikelyLinux  = 0
$Count_NoResponse_3389_22    = 0
$Count_WinRM_Down            = 0
$Count_WinRM_ExecutionError  = 0

$Results = @()   # local users report
$Triage  = @()   # triage/errors report

$StartTime = Get-Date
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "==========================================================" -ForegroundColor White
Write-Host " LOCAL USER AUDIT - WINDOWS (WITH RDP/SSH TRIAGE)" -ForegroundColor Cyan
Write-Host " Start: $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Gray
Write-Host " Total hosts: $TotalHosts" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor White

$i = 0

foreach ($Server in $Computers) {
    $i++
    $Server = ($Server -replace '"','').Trim()
    if (-not $Server) { continue }

    Write-Host "[$i/$TotalHosts] Checking: $Server..." -NoNewline

    # 1) Test RDP 3389 first
    $rdpOk = Test-TcpPort -ComputerName $Server -Port 3389 -TimeoutMs $TcpTimeoutMs

    if ($rdpOk) {
        # 2) If RDP is open, test WinRM
        if (Test-WSMan -ComputerName $Server -ErrorAction SilentlyContinue) {
            try {
                $LocalUsers = Invoke-Command -ComputerName $Server -Credential $Cred -ScriptBlock {
                    Get-LocalUser | Select-Object Name, Enabled
                } -ErrorAction Stop

                foreach ($u in $LocalUsers) {
                    $Results += [PSCustomObject]@{
                        Host    = $Server
                        User    = $u.Name
                        Enabled = $u.Enabled
                    }
                }

                Write-Host " [RDP OK | WINRM OK | COLLECTED]" -ForegroundColor Green
                $Count_Success++
            }
            catch {
                Write-Host " [RDP OK | WINRM OK | EXEC ERROR]" -ForegroundColor Red
                $Triage += [PSCustomObject]@{
                    Host   = $Server
                    Reason = "WinRM execution error (permissions or script failure)"
                }
                $Count_WinRM_ExecutionError++
            }
        }
        else {
            Write-Host " [RDP OK | WINRM DOWN]" -ForegroundColor Yellow
            $Triage += [PSCustomObject]@{
                Host   = $Server
                Reason = "WinRM not reachable (RDP port responded)"
            }
            $Count_WinRM_Down++
        }
    }
    else {
        # 3) If RDP not open, test SSH 22
        $Count_RDP_Down++

        $sshOk = Test-TcpPort -ComputerName $Server -Port 22 -TimeoutMs $TcpTimeoutMs
        if ($sshOk) {
            Write-Host " [RDP DOWN | SSH OK | LIKELY LINUX]" -ForegroundColor Cyan
            $Triage += [PSCustomObject]@{
                Host   = $Server
                Reason = "Likely Linux host (SSH 22 responded; RDP 3389 did not)"
            }
            $Count_SSH_Open_LikelyLinux++
        }
        else {
            Write-Host " [RDP DOWN | SSH DOWN]" -ForegroundColor Yellow
            $Triage += [PSCustomObject]@{
                Host   = $Server
                Reason = "No response on TCP ports 3389 and 22"
            }
            $Count_NoResponse_3389_22++
        }
    }
}

$Stopwatch.Stop()
$EndTime = Get-Date
$Duration = $Stopwatch.Elapsed

# -------------------------
# Export results
# -------------------------
if ($Triage.Count -gt 0) {
    $Triage | Export-Csv -Path $OutputTriageCsvPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
}
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $OutputUsersCsvPath -NoTypeInformation -Encoding UTF8 -Delimiter ";"
}

# -------------------------
# Summary
# -------------------------
Write-Host "`n==========================================================" -ForegroundColor White
Write-Host " SUMMARY" -ForegroundColor Cyan
Write-Host " Total hosts:                 $TotalHosts"
Write-Host " Collected (WinRM OK):        $Count_Success" -ForegroundColor Green
Write-Host " RDP 3389 Down:               $Count_RDP_Down" -ForegroundColor Yellow
Write-Host " Likely Linux (SSH 22 open):  $Count_SSH_Open_LikelyLinux" -ForegroundColor Cyan
Write-Host " No response (3389 & 22):     $Count_NoResponse_3389_22" -ForegroundColor Yellow
Write-Host " WinRM Down (RDP open):       $Count_WinRM_Down" -ForegroundColor Yellow
Write-Host " WinRM Execution Errors:      $Count_WinRM_ExecutionError" -ForegroundColor Red
Write-Host "----------------------------------------------------------"
Write-Host " Start:    $($StartTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host " End:      $($EndTime.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host " Duration: $($Duration.Minutes) min $($Duration.Seconds) sec" -ForegroundColor Cyan
Write-Host "----------------------------------------------------------"

if ($Triage.Count -gt 0) {
    Write-Host " Triage report: $OutputTriageCsvPath" -ForegroundColor Yellow
}
if ($Results.Count -gt 0) {
    Write-Host " Users report:  $OutputUsersCsvPath" -ForegroundColor Green
}

Write-Host "==========================================================" -ForegroundColor White
