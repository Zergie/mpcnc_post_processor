[CmdletBinding()]
param()

$table = Get-ChildItem $PSScriptRoot -Recurse -Filter *.cfg |
    Sort-Object Name |
    ForEach-Object `
        -Begin { 
            "| Gcode           | Description                    | config   |"
            "| --------------- | ------------------------------ | -------- |"
         } `
         -Process {
            $config = if ($_.Directory.Name -eq "optional") {"optional"} else {""}
            Get-Content $_ |
                ForEach-Object {
                    if ($_.StartsWith("[gcode_macro ")) {
                        if ($gcode.Length -gt 0) {
                            "| $($gcode.PadRight(15, ' ')) | $($description.PadRight(30, ' ')) | $($config.PadRight(8, ' ')) |"
                        }

                        $gcode = $_.Substring("[gcode_macro ".Length).Trim().TrimEnd(']')
                    } elseif ($gcode.Length -gt 0 -and $_.StartsWith("description:")) {
                        $description = $_.Substring("description: ".Length).Trim()

                        "| $($gcode.PadRight(15, ' ')) | $($description.PadRight(30, ' ')) | $($config.PadRight(8, ' ')) |"
                        
                        $gcode = ""
                        $description = ""
                    }
                }
         }

$insideTable = $false
$(
    Get-Content $PSScriptRoot\README.md |
         ForEach-Object {
            if ($_.StartsWith("| Gcode ")) {
                $insideTable = $true
            }

            if ($insideTable) { 
            } else {
                $_
            }
         }
    $table
) | 
    ForEach-Object {
        Write-Host $_
        $_
    } |
    Out-String |
    Set-Content $PSScriptRoot\README.md