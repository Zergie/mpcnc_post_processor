[CmdletBinding()]
param()
$klipper_url = "10.0.0.17"
$klipper_user = "mks"
$gcode = @(
    "RESTART"
    "G28"
    "G54 G0 X0 Y0"
    "START_PRINT X=0,100 Y=0,100 Z=0,1"
)

git add .
git commit --amend --no-edit

Write-Host
Write-Host -ForegroundColor Cyan "Installing on ${klipper_url}"
ssh ${klipper_user}@${klipper_url} "git -C ~/mpcnc_post_processor fetch; git -C ~/mpcnc_post_processor reset --hard origin/main"

$last_message = (Invoke-RestMethod -Uri http://${klipper_url}:7125/server/gcode_store?count=10).result.gcode_store |
                    Select-Object -Last 1

$gcode |
    ForEach-Object {
        Write-Host -ForegroundColor Cyan -NoNewline "Running gcode '$_'"
        "http://${klipper_url}:7125/printer/gcode/script?script=$_"
    } |
    ForEach-Object {
        $uri = $_
        Invoke-RestMethod -Method Post -Uri $uri -SkipHttpErrorCheck |
            ForEach-Object {
                Write-Host -NoNewline ' '
                if ($uri.EndsWith("=RESTART")) {
                    5..1 | 
                        ForEach-Object { 
                            Write-Host -ForegroundColor Cyan -NoNewline "$_ "
                            Start-Sleep -Seconds 1
                        }
                }
                if ($null -eq $_.error) {
                    Write-Host -ForegroundColor Green $_.result
                } elseif ($_.error.message) {
                    Write-Host -ForegroundColor Red ($_.error.message | ConvertFrom-Json).message
                }
                (Invoke-RestMethod -Uri http://${klipper_url}:7125/server/gcode_store?count=10).result.gcode_store |
                    Where-Object time -gt $last_message.time -OutVariable messages |
                    ForEach-Object message |
                    Write-Host -ForegroundColor Yellow
                $last_message = $messages | Select-Object -Last 1
            }
    }
