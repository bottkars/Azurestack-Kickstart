# short update script
Push-Location
Set-Location $PSScriptRoot
git pull
git submodule
Set-Location ./pcf
git submodule update --init
git checkout master
git pull
Pop-Location