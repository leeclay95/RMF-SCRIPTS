#Created by Lee clayton for home edition demo. This script is to be used with google chrome to implement STIGs via the registry.

param(
    [Parameter(Mandatory = $false)][bool]$chrome = $false
)

# Require elevation
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This script must be run as Administrator."
    exit 1
}

# Function: Apply Chrome STIG settings via registry
function Apply-ChromeSTIG {
    Write-Host "`n[+] Applying Chrome STIG Settings..." -ForegroundColor Cyan

    # Use the full registry path with the Registry:: prefix.
    $chromeKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome"

    # Create base key if it doesn't exist
    if (-not (Test-Path $chromeKey)) {
        New-Item -Path $chromeKey -Force | Out-Null
    }

    # Define STIG-aligned registry settings
    $settings = @{
        PasswordManagerEnabled                    = 0
        BackgroundModeEnabled                     = 0
        SyncDisabled                              = 1
        MetricsReportingEnabled                   = 0
        DefaultCookiesSetting                     = 4   # Session-only
        AllowDeletingBrowserHistory               = 0
        SavingBrowserHistoryDisabled              = 0
        IncognitoModeAvailability                 = 1
        AutofillAddressEnabled                    = 0
        AutofillCreditCardEnabled                 = 0
        ImportSavedPasswords                      = 0
        ImportAutofillFormData                    = 0
        SearchSuggestEnabled                      = 0
        PromptForDownloadLocation                 = 1
        DefaultGeolocationSetting                 = 2
        DefaultPopupsSetting                      = 2
        DefaultWebUsbGuardSetting                 = 2
        DefaultWebBluetoothGuardSetting           = 2
        EnableMediaRouter                         = 0
        WebRtcEventLogCollectionAllowed           = 0
        UrlKeyedAnonymizedDataCollectionEnabled   = 0
        DeveloperToolsAvailability                = 2
        BrowserGuestModeEnabled                   = 0
        QuicAllowed                               = 0
        ChromeCleanupEnabled                      = 0
        ChromeCleanupReportingEnabled             = 0
        SafeBrowsingExtendedReportingEnabled      = 0
        SafeBrowsingProtectionLevel               = 1
        DownloadRestrictions                      = 1
        EnableOnlineRevocationChecks              = 1
        SSLVersionMin                             = "tls1.2"
        DefaultSearchProviderEnabled              = 1
        DefaultSearchProviderName                 = "Google Encrypted"
        DefaultSearchProviderSearchURL            = "https://www.google.com/search?q={searchTerms}"
    }

    foreach ($key in $settings.Keys) {
        $value = $settings[$key]
        if ($value -is [int]) {
            Set-ItemProperty -Path $chromeKey -Name $key -Value $value -Type DWord -Force
        } else {
            Set-ItemProperty -Path $chromeKey -Name $key -Value $value -Type String -Force
        }
        Write-Host " → Set $key = $value"
    }

    # Allowlist .mil and .gov for autoplay
    $autoplayKey = "$chromeKey\AutoplayAllowlist"
    if (-not (Test-Path $autoplayKey)) {
        New-Item -Path $autoplayKey -Force | Out-Null
    }
    Set-ItemProperty -Path $autoplayKey -Name "1" -Value "[*.]mil" -Type String -Force
    Set-ItemProperty -Path $autoplayKey -Name "2" -Value "[*.]gov" -Type String -Force
    Write-Host " → Set AutoplayAllowlist for .mil and .gov domains"

    # Block all extensions except allowlist
    Set-ItemProperty -Path $chromeKey -Name "ExtensionInstallBlocklist" -Value "*" -Type String -Force
    $extAllowKey = "$chromeKey\ExtensionInstallAllowlist"
    if (-not (Test-Path $extAllowKey)) {
        New-Item -Path $extAllowKey -Force | Out-Null
    }
    Set-ItemProperty -Path $extAllowKey -Name "1" -Value "oiigbmnaadbkfbmpbfijlflahbdbdgdf" -Type String -Force

    # Block specific URLs
    $urlBlockKey = "$chromeKey\URLBlocklist"
    if (-not (Test-Path $urlBlockKey)) {
        New-Item -Path $urlBlockKey -Force | Out-Null
    }
    Set-ItemProperty -Path $urlBlockKey -Name "1" -Value "javascript://*" -Type String -Force

    Write-Host "`n✅ Chrome STIG settings applied successfully."
}

# === MAIN ===
Write-Host "`n==============================="
Write-Host "===============================" -ForegroundColor Yellow

if ($chrome -eq $true) {
    Apply-ChromeSTIG
} else {
    Write-Warning "⚠️  No switches selected. Run with '-chrome \$true' to apply Chrome hardening."
}

Write-Host "`n⚠️  A reboot is recommended for all changes to take effect." -ForegroundColor Magenta
