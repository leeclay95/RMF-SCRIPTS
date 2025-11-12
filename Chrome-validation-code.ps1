
# Retrieve current installed version of Google Chrome
try {
    $chromePath = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe' -ErrorAction Stop).'(default)'
    $currentVersion = (Get-Item $chromePath).VersionInfo.ProductVersion
} catch {
    $currentVersion = $null
}

# Retrieve latest version from Google Update service (stable channel, Windows)
try {
    $url = "https://versionhistory.googleapis.com/v1/chrome/platforms/win/channels/stable/versions"
    $response = Invoke-RestMethod -Uri $url -UseBasicParsing -ErrorAction Stop
    $latestVersion = $response.versions[0].version
} catch {
    $latestVersion = $null
}

# Compare and prepare results
$ValidationResults = [PSCustomObject]@{
    Results = ""
    Valid   = $false
}

if ($null -eq $currentVersion) {
    $ValidationResults.Results = "Chrome not found on this system."
    $ValidationResults.Valid = $false
} elseif ($null -eq $latestVersion) {
    $ValidationResults.Results = "Unable to determine latest Chrome version from Google API."
    $ValidationResults.Valid = $false
} else {
    $ValidationResults.Results = "Current Chrome Version: $currentVersion | Latest Available: $latestVersion"
    if ([version]$currentVersion -ge [version]$latestVersion) {
        $ValidationResults.Valid = $true
    } else {
        $ValidationResults.Valid = $false
    }
}

return $ValidationResults








<#
.SYNOPSIS
  Adds a one-time self-deletion timer after first execution.
#>

# --- CONFIGURATION ---
[int]$ExpireHours = 24       # change to 0.0167 (≈1 min) for testing
[string]$TaskName = "SelfDelete_$([guid]::NewGuid())"
# ----------------------

# Path of the running script
$ScriptPath = $MyInvocation.MyCommand.Path

# Metadata file to mark first run
$MetaFile = "$env:ProgramData\$(Split-Path $ScriptPath -Leaf).meta"

# Create metadata and scheduled cleanup on first run
if (-not (Test-Path $MetaFile)) {
    (Get-Date).ToString('o') | Out-File $MetaFile -Encoding utf8
    $ExpireAt = (Get-Date).AddHours($ExpireHours)

    # Create a one-time scheduled task that deletes this file at expiry
    $Trigger = New-ScheduledTaskTrigger -Once -At $ExpireAt
    $Action  = New-ScheduledTaskAction -Execute 'powershell.exe' `
               -Argument "-NoProfile -Command `"Remove-Item -Force '$ScriptPath'; Remove-Item -Force '$MetaFile'`""
    Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action | Out-Null

    Write-Host "Self-delete scheduled for $ExpireAt"
} else {
    Write-Host "Timer already set. Script will delete after $ExpireHours hours."
}
