Push-Location
Set-Location $PSScriptRoot
git pull
cd ./pcf
git submodule
git submodule init
git checkout master
git pull
Pop-Location
