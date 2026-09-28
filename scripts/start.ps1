#Requires -Version 5.1
# 0. Réglages
$ErrorActionPreference = 'Stop'
$ProgressPreference   = 'SilentlyContinue'          # 41 s -> 0,9 s pour 23 Mo (mesuré)
try { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch {}   # évite le mojibake du résumé de build Hugo
# PSModulePath hérité d'un terminal PowerShell 7 (VS Code, Windows Terminal) : Windows PowerShell 5.1 y trouve d'abord
# les modules de PowerShell 7, Get-FileHash disparaît (CommandNotFoundException) et Expand-Archive vient de la 1.2.x
# de PS 7. Reproduit le 2026-09-23 (start.bat lancé via cmd.exe depuis pwsh 7) : on repart des chemins propres à 5.1.
$env:PSModulePath = "$PSHOME\Modules;$env:ProgramFiles\WindowsPowerShell\Modules"
$Port = 1313
$Url  = "http://127.0.0.1:$Port/admin/"               # 127.0.0.1 (pas localhost -> ::1) ; /admin/ (index.html -> 301)
$script:p = $null                                     # processus Hugo, renseigné à l'étape 5

function Stop-WithMessage([string]$msg) {
  Write-Host ''; Write-Host "ERREUR : $msg" -ForegroundColor Red
  Write-Host 'Si le problème persiste, demandez de l''aide en montrant cette fenêtre (voir AIDE.md).'
  # Ne jamais laisser une instance Hugo orpheline sur 1313 (E_TIMEOUT, E_HUGO…)
  if ($script:p -and -not $script:p.HasExited) { Stop-Process -Id $script:p.Id -Force -ErrorAction SilentlyContinue }
  exit 1                                              # start.bat fait « pause »
}
function Test-PortOpen([int]$port) {
  # Vrai dès qu'un programme accepte la connexion (HTTP ou non) ; suffit seul, sans Get-NetTCPConnection.
  # ConnectAsync + Wait(500) et non Connect() : sur port fermé, Connect() coûte ~2,1 s sous Windows (le SYN est
  # réémis après le RST), contre ~0,5 s ici ; sur port ouvert la boucle locale répond en < 10 ms (mesuré 2026-09-23).
  $c = New-Object Net.Sockets.TcpClient
  try { $t = $c.ConnectAsync('127.0.0.1', $port); ($t.Wait(500) -and $c.Connected) } catch { $false } finally { $c.Close() }
}
function Test-AdminReady([int]$port) {
  # Vrai seulement quand Hugo sert réellement le CMS (200 sur /admin/), pas juste quand le port est ouvert
  try { (Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:$port/admin/" -TimeoutSec 3).StatusCode -eq 200 } catch { $false }
}
function Open-Browser([string]$u) {
  # SITE_SANS_NAVIGATEUR=1 (tests automatisés) : aucun navigateur, ni à l'étape 4 (« Le site tourne déjà ») ni à l'étape 7
  if ($env:SITE_SANS_NAVIGATEUR -eq '1') { return }
  # App Paths : chrome.exe puis msedge.exe, HKCU (installation par utilisateur) puis HKLM
  $browser = $null
  foreach ($n in 'chrome.exe','msedge.exe') {
    foreach ($h in 'HKCU:','HKLM:') {
      $pp = (Get-ItemProperty -LiteralPath "$h\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$n" -ErrorAction SilentlyContinue).'(default)'
      if ($pp -and (Test-Path -LiteralPath $pp)) { $browser = $pp; break }
    }
    if ($browser) { break }
  }
  if ($browser) { Start-Process -FilePath $browser -ArgumentList $u }
  else {
    try { Start-Process $u } catch {}
    Write-Host "ATTENTION : Chrome ou Edge n'a pas été trouvé. Le navigateur par défaut a été ouvert, mais l'éditeur ne fonctionne qu'avec Chrome ou Edge." -ForegroundColor Yellow
  }
}

# 1. Racine du dépôt
$Root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $Root
if (-not (Test-Path -LiteralPath '.hugo-version')) { Stop-WithMessage 'le fichier .hugo-version est introuvable. Ce script doit rester dans le dossier scripts/ du projet.' }

# 2. Version
$Ver = (Get-Content -LiteralPath '.hugo-version' -Raw).Trim()
if ($Ver -notmatch '^\d+\.\d+\.\d+$') { Stop-WithMessage "le fichier .hugo-version est invalide (« $Ver »)." }
$ToolDir = Join-Path $Root ".tools\hugo-$Ver"
$Exe     = Join-Path $ToolDir 'hugo.exe'

# 3. Téléchargement si nécessaire
if (-not (Test-Path -LiteralPath $Exe)) {
  $IsArm = ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') -or ($env:PROCESSOR_ARCHITEW6432 -eq 'ARM64')
  try { if ((Get-CimInstance Win32_Processor -ErrorAction Stop | Select-Object -First 1).Architecture -eq 12) { $IsArm = $true } } catch {}
  $Arch  = if ($IsArm) { 'arm64' } else { 'amd64' }
  $Asset = "hugo_${Ver}_windows-$Arch.zip"
  $Sums  = "hugo_${Ver}_checksums.txt"
  $Base  = "https://github.com/gohugoio/hugo/releases/download/v$Ver"
  $Tmp   = Join-Path $Root ".tools\tmp-$([guid]::NewGuid().ToString('N'))"
  New-Item -ItemType Directory -Force -Path $Tmp | Out-Null

  Write-Host "Téléchargement d'Hugo $Ver (une seule fois, environ 20 Mo)…"
  try {
    Invoke-WebRequest -UseBasicParsing -Uri "$Base/$Asset" -OutFile (Join-Path $Tmp $Asset)
    Invoke-WebRequest -UseBasicParsing -Uri "$Base/$Sums"  -OutFile (Join-Path $Tmp $Sums)
  } catch {
    Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
    Stop-WithMessage "téléchargement impossible. Vérifiez votre connexion Internet, puis relancez. ($($_.Exception.Message))"
  }

  Write-Host 'Vérification du fichier téléchargé…'
  # Tout le bloc est sous try/catch : quelle que soit l'exception (attendue ou non), le dossier temporaire et son zip
  # de 20 Mo sont supprimés et le message passe par Stop-WithMessage (reproduit sans cela : zip laissé dans .tools\tmp-*).
  $msg = $null
  try {
    $pattern = '^([0-9a-fA-F]{64})  ' + [regex]::Escape($Asset) + '$'      # deux espaces, ancré en fin de ligne
    $lines = @(Get-Content -LiteralPath (Join-Path $Tmp $Sums) | Where-Object { $_ -match $pattern })
    if ($lines.Count -ne 1) { $msg = "le fichier de contrôle ne mentionne pas $Asset."; throw $msg }
    $expected = ($lines[0] -split '  ')[0]
    # SHA-256 par .NET, sans Get-FileHash (fonction du module Utility, absente si PSModulePath vient de PowerShell 7,
    # voir l'étape 0). Résultat en MAJUSCULES ; -ne est insensible à la casse (le fichier de contrôle est en minuscules).
    $sha = [Security.Cryptography.SHA256]::Create()
    $fs  = [IO.File]::OpenRead((Join-Path $Tmp $Asset))
    try { $actual = ([BitConverter]::ToString($sha.ComputeHash($fs)) -replace '-', '') } finally { $fs.Close(); $sha.Dispose() }
    if ($actual -ne $expected) {
      $msg = "le fichier téléchargé est corrompu ou modifié (empreinte différente). Il a été supprimé : relancez le script."
      throw $msg
    }
  } catch {
    Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
    if (-not $msg) { $msg = "vérification du fichier téléchargé impossible. Relancez le script. ($($_.Exception.Message))" }
    Stop-WithMessage $msg
  }

  Write-Host 'Installation dans .tools…'
  try {
    New-Item -ItemType Directory -Force -Path $ToolDir | Out-Null
    Expand-Archive -LiteralPath (Join-Path $Tmp $Asset) -DestinationPath $ToolDir -Force
  } catch { Stop-WithMessage "impossible d'installer Hugo (extraction). ($($_.Exception.Message))" }
  Unblock-File -LiteralPath $Exe -ErrorAction SilentlyContinue
  Remove-Item -LiteralPath $Tmp -Recurse -Force -ErrorAction SilentlyContinue
  if (-not (Test-Path -LiteralPath $Exe)) { Stop-WithMessage "hugo.exe est introuvable après extraction dans $ToolDir." }
  $vout = & $Exe version
  if ($vout -notmatch "^hugo v$([regex]::Escape($Ver))") { Stop-WithMessage "la version installée ne correspond pas : $vout" }
  Write-Host "Hugo $Ver installé dans .tools\hugo-$Ver\"
}

# 4. Port : TcpClient seul. (Get-NetTCPConnection abandonné : si le cmdlet manque, CommandNotFoundException
#    n'est PAS masquée par -ErrorAction SilentlyContinue et, avec $ErrorActionPreference = 'Stop', le script
#    mourrait avant le repli — reproduit.)
if (Test-PortOpen $Port) {
  if (Test-AdminReady $Port) {
    Write-Host "Le site tourne déjà (une autre fenêtre de lancement est ouverte). Ouverture de l'éditeur…"
    Open-Browser $Url; Start-Sleep -Seconds 2; exit 0
  }
  Stop-WithMessage "le port $Port est déjà utilisé par un autre programme. Fermez-le (ou l'autre fenêtre de lancement), puis relancez."
}

# 5. Hugo (même console : la fermeture de la fenêtre doit arrêter Hugo)
Write-Host 'Démarrage du site…'
$script:p = Start-Process -FilePath $Exe -WorkingDirectory $Root -NoNewWindow -PassThru `
  -ArgumentList @('server','--bind','127.0.0.1','--port',"$Port",'--buildDrafts','--environment','development')
$p = $script:p
$null = $p.Handle   # OBLIGATOIRE sous PS 5.1 : sans handle mis en cache, $p.ExitCode reste $null après la fin (reproduit)
# Filet : si la console se ferme (croix de la fenêtre), tenter d'arrêter Hugo
# L'action d'un événement ne voit pas les variables du script : l'Id passe par -MessageData / $Event.MessageData
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -SupportEvent -MessageData $p.Id -Action {
  try { Stop-Process -Id $Event.MessageData -Force -ErrorAction SilentlyContinue } catch {}
}

# 6. Attente : HTTP 200 sur /admin/ (pas une simple connexion TCP : Hugo ouvre le port avant la fin du 1er build)
$deadline = (Get-Date).AddSeconds(60)
while (-not (Test-AdminReady $Port)) {
  if ($p.HasExited) {
    Start-Sleep -Milliseconds 300
    if (Test-PortOpen $Port) {   # Hugo est mort sur « bind: address already in use » : ce n'est pas une erreur de contenu
      Stop-WithMessage "le port $Port est déjà utilisé par un autre programme. Fermez-le (ou l'autre fenêtre de lancement), puis relancez."
    }
    Stop-WithMessage "Hugo s'est arrêté tout de suite (code $($p.ExitCode)). Lisez le message ci-dessus : c'est souvent une erreur dans un article."
  }
  if ((Get-Date) -gt $deadline) { Stop-WithMessage 'le site ne répond pas après 60 secondes.' }   # Stop-WithMessage arrête Hugo
  Start-Sleep -Milliseconds 300
}

# 7. Navigateur (SITE_SANS_NAVIGATEUR=1 : aucun navigateur n'est ouvert — garde dans Open-Browser, pour les tests automatisés)
Open-Browser $Url

# 8. Récapitulatif
Write-Host ''
Write-Host "  Site         : http://127.0.0.1:$Port/" -ForegroundColor Green
Write-Host "  Édition      : $Url" -ForegroundColor Green
Write-Host '  Pour arrêter : fermez simplement cette fenêtre.'
Write-Host ''

# 9. Attente d'Hugo
try { Wait-Process -Id $p.Id } finally { try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {} }
# Garde $null : sans handle mis en cache, $null -ne 0 serait vrai et start.bat ferait « pause » à chaque arrêt normal (reproduit)
if ($null -ne $p.ExitCode -and $p.ExitCode -ne 0) { Stop-WithMessage "Hugo s'est arrêté avec le code $($p.ExitCode)." }
exit 0
