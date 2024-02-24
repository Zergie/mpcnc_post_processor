[CmdletBinding()]
param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]
    $Url = "trident.local",

    [Parameter(Mandatory = $true,
               Position = 1)]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Path,

    [Parameter(Mandatory = $false)]
    [int]
    $Seconds = 1
)

Write-Host "Watching folder '$Path'"

while (1) {
    foreach ($p in $Path) {
        Get-ChildItem -Path $p -Filter $Filter -ErrorAction SilentlyContinue |
            ForEach-Object {
                . "$PSScriptRoot\Upload-File.ps1" -Url $url -Path $_  -Start
                Remove-Item $_
            }
        Start-Sleep -Seconds $Seconds
    }
}
