<#
.DESCRIPTION
    Update all installed applications using Winget (Windows)

.NOTES
    Last Edit: 2024-05-19
    Version 1.0 - initial release
#>

########################
# Script Settings
########################

########################
# Begin Script Function
#######################

function Get-WingetVersion {
    $wingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source
    if ($wingetPath) {
        $versionOutput = winget --version
        if ($versionOutput) {
            $version = $versionOutput -match "v([\d\.]+)" | Out-Null
            return $matches[1]
        }
    }
    return $null
}

function Install-Or-Update-Winget {
    $installerUrl = "https://aka.ms/getwinget"
    $installerPath = "$env:TEMP\Microsoft.DesktopAppInstaller.msi"

    Write-Host "Downloading winget installer..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

    if (Test-Path $installerPath) {
        Write-Host "Installing/updating winget..."
        Start-Process msiexec.exe -ArgumentList "/i", $installerPath, "/quiet", "/norestart" -NoNewWindow -Wait

        if ($LASTEXITCODE -eq 0) {
            Write-Host "winget has been successfully installed/updated."
        } else {
            Write-Host "Failed to install/update winget. Exit code: $LASTEXITCODE"
        }

        Remove-Item $installerPath -Force
    } else {
        Write-Host "Failed to download the winget installer."
    }
}

function Check-Winget {
    $wingetVersion = Get-WingetVersion
    if ($wingetVersion) {
        Write-Host "Current winget version: $wingetVersion"
        if ([version]$wingetVersion -lt [version]"1.7") {
            Write-Host "winget version is older than 1.7. Updating winget..."
            Install-Or-Update-Winget
        } else {
            Write-Host "winget is up to date."
        }
    } else {
        Write-Host "winget is not installed. Installing winget..."
        Install-Or-Update-Winget
    }
}

function Update-AllSoftware {
    Check-Winget
    if (Get-WingetVersion) {
        Write-Host "Updating all installed applications using winget..."
        winget upgrade --all --silent --accept-source-agreements --accept-package-agreements
        Write-Host "Update completed."
    } else {
        Write-Host "winget is not installed. The script cannot continue."
    }
}

Update-AllSoftware
