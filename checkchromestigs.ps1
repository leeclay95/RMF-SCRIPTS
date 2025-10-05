# Define registry paths for Chrome policies
$regPaths = @(
    "HKLM:\SOFTWARE\Policies\Google\Chrome",
    "HKCU:\SOFTWARE\Policies\Google\Chrome"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Write-Host "`nPolicies set under: $path`n" -ForegroundColor Cyan
        Get-ItemProperty -Path $path | ForEach-Object {
            $_.PSObject.Properties | ForEach-Object {
                Write-Output "$($_.Name) = $($_.Value)"
            }
        }
    } else {
        Write-Host "`nNo policies found at: $path" -ForegroundColor DarkGray
    }
}
