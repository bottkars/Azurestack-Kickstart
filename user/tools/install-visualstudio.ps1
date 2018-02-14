[CmdletBinding()]
param (
[Parameter(Mandatory = $true)][ValidateSet("Community","Professional'","Enterprise")]$edition,
[Parameter(Mandatory = $true)][ValidateSet('cs-CZ','de-DE','en-US','es-ES','fr-FR','it-IT','ja-JP','ko-KR','pl-PL','pt-BR','ru-RU','tr-TR','zh-CN','zh-TW')]$lang
)

#### parsing ssms version

## 

switch ($edition)
    {
        'Community'
        {
        $URI = 'https://aka.ms/vs/15/release/vs_community.exe'
        }

        'Professional'
        {
        $URI = 'https://aka.ms/vs/15/release/vs_professional.exe'
        }

        'Enterprise'
        {
        $URI = 'https://aka.ms/vs/15/release/vs_enterprise.exe'
        }
    }
$Request = Invoke-WebRequest -MaximumRedirection 0 -UseBasicParsing $URI -ErrorAction SilentlyContinue
$Outfile = split-path -Leaf $Request.Headers.Location
Invoke-WebRequest -OutFile "$Home/Downloads/$($outfile)" -Uri $Request.Headers.Location
Unblock-File "$Home/Downloads/$Outfile"
Start-Process -FilePath "$Home/Downloads/$Outfile" -ArgumentList "--layout $Home/Downloads/vs2017offline --add Microsoft.VisualStudio.Workload.Azure --add Component.GitHub.VisualStudio --includeOptional  --lang $lang" -wait -PassThru
Start-Process -FilePath "$Home/Downloads/vs2017offline\$Outfile" -ArgumentList "--add Microsoft.VisualStudio.Workload.Azure --add Component.GitHub.VisualStudio --includeOptional --wait --norestart" -Wait -PassThru


