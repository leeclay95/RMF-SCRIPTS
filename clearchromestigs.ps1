# ===============================
# Script: Clear Chrome GPO Settings
# ===============================

# Registry paths for Chrome GPOs
$chromeGpoPaths = @(
    "HKLM:\SOFTWARE\Policies\Google\Chrome",
    "HKCU:\SOFTWARE\Policies\Google\Chrome"
)

foreach ($path in $chromeGpoPaths) {
    if (Test-Path $path) {
        Write-Host "`nClearing Chrome GPO settings from: $path" -ForegroundColor Cyan

        # Get all property names (registry values)
        $props = (Get-ItemProperty -Path $path).PSObject.Properties.Name

        foreach ($prop in $props) {
            try {
                Remove-ItemProperty -Path $path -Name $prop -ErrorAction Stop
                Write-Host "Removed policy: $prop"
            } catch {
                Write-Warning "Failed to remove ${prop}: $($_)"
            }
        }

        # If no values left, remove the entire Chrome policy key
        try {
            $remainingProps = (Get-ItemProperty -Path $path).PSObject.Properties.Name
            if ($remainingProps.Count -eq 0) {
                Remove-Item -Path $path -Force
                Write-Host "Removed empty Chrome GPO key: $path"
            }
        } catch {
            Write-Warning "Failed to clean key: $($_)"
        }

    } else {
        Write-Host "No Chrome GPO settings found at: $path"
    }
}