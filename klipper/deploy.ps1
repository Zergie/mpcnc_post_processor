$klipper_url = "trident.local"
$klipper_user = "biqu"
$gcode = @(
    # "G28"
    "G92.3"
    "G56"
    "G92 X10 Y10"
)


$restart_job = Start-Job {
    Invoke-RestMethod `
        -Method Post `
        -Uri "http://$($using:klipper_url):7125/printer/firmware_restart" `
        -SkipHttpErrorCheck

    $success = $false
    while (!$success) {
        Start-Sleep -Seconds 1
        $response = Invoke-RestMethod `
                        -Method Post `
                        -Uri "http://$($using:klipper_url):7125/printer/gcode/script?script=M117" `
                        -SkipHttpErrorCheck
        $success = !($null -ne $response.error)
    }
}

git add .
git commit --amend --no-edit
git push -f

Write-Host
Write-Host -ForegroundColor Cyan "== Installing on ${klipper_url} =="
ssh ${klipper_user}@${klipper_url} "cd ~/mpcnc_post_processor; git fetch; git reset --hard origin/master"


Write-Host
Write-Host -ForegroundColor Cyan "== Waiting for klipper to RESTART =="
Wait-Job -TimeoutSec 10 $restart_job | Out-Null
Remove-Job $restart_job | Out-Null
$last_message = (Invoke-RestMethod -Uri http://${klipper_url}:7125/server/gcode_store?count=10).result.gcode_store |
    Where-Object message -eq M117 |
    Select-Object -Last 1

Write-Host
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
