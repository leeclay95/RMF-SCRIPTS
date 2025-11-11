
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








Current version: Pulled from registry key for chrome.exe.

Latest version: Pulled directly from Google’s public API (versionhistory.googleapis.com).

Comparison: Uses [version] type-safe comparison to avoid string mismatches.

Return: A [PSCustomObject] with:

Results → comment text showing both versions.

Valid → $true if current ≥ latest; $false otherwise.

Statuses: Automatically updates STIG check to NotAFinding or Open based on result.