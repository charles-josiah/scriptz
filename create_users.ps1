# Active Directory Bulk User Creation Script

This PowerShell script automates the creation of multiple users in Active Directory (AD) in a consistent and controlled manner.

## Features

- Bulk user creation from structured in-script data
- Automatic username normalization (lowercase)
- Enforced password change at first logon
- Duplicate detection (both in input list and AD)
- Organizational Unit (OU) validation before execution
- Execution summary (created, existing, errors)
- Safe error handling and logging

## Requirements

- Windows Server with Active Directory module
- RSAT tools installed
- Appropriate permissions to create users in AD

## Usage

1. Adjust the following variables:
   - Target OU (Distinguished Name)
   - Domain UPN suffix
   - Default password (ensure compliance with domain policy)

2. Run the script:

```powershell
powershell -ExecutionPolicy Bypass -File .\create_users.ps1


---

## 📜 Script PowerShell

```powershell
Import-Module ActiveDirectory

# ==============================
# CONFIGURATION
# ==============================
$OUPath      = "OU=example,DC=domain,DC=local"
$DomainUPN   = "domain.local"
$DefaultPass = ConvertTo-SecureString "ChangeMe123!" -AsPlainText -Force

$Created    = @()
$Existing   = @()
$Errors     = @()

# ==============================
# SAMPLE USER DATA (ANONYMIZED)
# ==============================
$Users = @(
    [PSCustomObject]@{SamAccountName="user01"; NomeCompleto="User One"},
    [PSCustomObject]@{SamAccountName="user02"; NomeCompleto="User Two"},
    [PSCustomObject]@{SamAccountName="user03"; NomeCompleto="User Three"},
    [PSCustomObject]@{SamAccountName="user04"; NomeCompleto="User Four"},
    [PSCustomObject]@{SamAccountName="user05"; NomeCompleto="User Five"}
)

# ==============================
# REMOVE DUPLICATES
# ==============================
$UsersUnique = $Users | Sort-Object SamAccountName -Unique

# ==============================
# NAME SPLIT FUNCTION
# ==============================
function Get-NameParts {
    param([string]$FullName)

    $parts = $FullName.Trim() -split '\s+'

    if ($parts.Count -le 1) {
        return [PSCustomObject]@{
            GivenName = $FullName
            Surname   = $FullName
        }
    }

    return [PSCustomObject]@{
        GivenName = $parts[0]
        Surname   = ($parts[1..($parts.Count - 1)] -join ' ')
    }
}

# ==============================
# VALIDATE OU
# ==============================
try {
    Get-ADOrganizationalUnit -Identity $OUPath -ErrorAction Stop | Out-Null
    Write-Host "OU validated: $OUPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: OU not found: $OUPath" -ForegroundColor Red
    return
}

# ==============================
# USER CREATION LOOP
# ==============================
foreach ($u in $UsersUnique) {
    $sam = $u.SamAccountName.ToLower()
    $fullName = $u.NomeCompleto
    $upn = "$sam@$DomainUPN"

    Write-Host "Processing: $sam" -ForegroundColor Cyan

    $name = Get-NameParts -FullName $fullName

    try {
        $existingUser = Get-ADUser -LDAPFilter "(sAMAccountName=$sam)" -ErrorAction SilentlyContinue

        if ($existingUser) {
            Write-Host "Already exists: $sam" -ForegroundColor Yellow
            $Existing += $sam
            continue
        }

        New-ADUser `
            -Name $fullName `
            -DisplayName $fullName `
            -GivenName $name.GivenName `
            -Surname $name.Surname `
            -SamAccountName $sam `
            -UserPrincipalName $upn `
            -Path $OUPath `
            -AccountPassword $DefaultPass `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false `
            -Description "Bulk-created user (anonymized example)"

        Write-Host "Created: $sam" -ForegroundColor Green
        $Created += $sam
    }
    catch {
        Write-Host "Error creating $sam : $($_.Exception.Message)" -ForegroundColor Red
        $Errors += "$sam - $($_.Exception.Message)"
    }
}

# ==============================
# SUMMARY
# ==============================
Write-Host ""
Write-Host "========== SUMMARY ==========" -ForegroundColor Cyan
Write-Host "Created:    $($Created.Count)"
Write-Host "Existing:   $($Existing.Count)"
Write-Host "Errors:     $($Errors.Count)"
