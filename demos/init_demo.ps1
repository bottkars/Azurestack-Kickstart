### set you git username !!!!
$global:gitusername = "bottkars"
## create below repo in you git !!!!
$repo = "my_appservice_html5_demo" 

##do ot change the upstreams, we´re mirroring them"
$upstream = "appservice_html5_demo"
$upstream_repo = "https://github.com/bottkars/$upstream"
Set-Location $Home

git clone $upstream_repo
New-Item -ItemType Directory "$Home/$repo"
set-location "$HOME/$repo"
git init
set-content -path $HOME/$repo/README.md -Value "README for AppDemo"
git add README.md
git commit -m 'first commit'
git remote add origin "https://github.com/$($global:gitusername)/$repo"
git push origin master

Set-Location "$HOME/$Upstream"
git remote set-url --push origin "https://github.com/$($global:gitusername)/$repo.git"
git push --mirror "https://github.com/$($global:gitusername)/$repo"

Set-Location $HOME
Remove-Item $upstream -Recurse -Force -Confirm:$false