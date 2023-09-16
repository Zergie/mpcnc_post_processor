git add .
git commit --amend --no-edit
git push -f

Write-Host
Write-Host "== installing on trident =="
ssh biqu@trident "cd ~/mpcnc_post_processor; git fetch; git reset --hard origin/master"

Write-Host
Write-Host "Please run 'FIRMWARE_RESTART' in klipper"
