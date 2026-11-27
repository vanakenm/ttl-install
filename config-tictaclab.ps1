# =============================================================================
#  config-tictaclab.ps1 - Configuration des laptops Tic Tac Lab (Windows 11)
#
#  Lancer en double-cliquant sur "lancer.cmd" (il demande les droits admin),
#  ou dans un PowerShell administrateur :
#     powershell -ExecutionPolicy Bypass -File .\config-tictaclab.ps1 -NomPC ttl-02
#
#  Options :
#     -NomPC ttl-02     renomme la machine (redemarrage necessaire)
#     -Laser            installe aussi LightBurn (PC de la decoupeuse laser)
#     -SansDell         saute les mises a jour BIOS/pilotes Dell
#
#  Le script peut etre relance sans danger : ce qui est deja fait est saute.
# =============================================================================
param(
  [string]$NomPC = "",
  [switch]$Laser,
  [switch]$SansDell
)

# ----------------------------------------------------------------------------
#  REGLAGES - a adapter
# ----------------------------------------------------------------------------
# Compte des enfants : compte STANDARD, sans droits admin.
$EleveUser = "techies"           # nom de connexion (identique sur tous les laptops)
$EleveNom  = ""                  # nom affiché à l'écran ; vide = nom de la machine (ex. techies13)
$EleveMdp  = "codingrobot"       # mot de passe fixe des enfants
$AutoLogin = $false              # $true = session élève ouverte automatiquement

# Compte administrateur : c'est son mot de passe que Windows demandera
# pour installer un logiciel ou changer un réglage protégé.
$AdminUser    = "ttl-admin"
$AncienAdmin  = "ttl-u01"        # compte admin actuel : renommé en ttl-admin (il garde son mot de passe)
$AdminMdp     = ""               # vide = on ne touche pas au mot de passe actuel
$MasquerAdmin = $false           # $true = le compte admin n'apparaît plus à l'écran de connexion
                                 # (il reste utilisable quand Windows demande le mot de passe admin)

# Onglets ouverts au démarrage (Firefox, Chrome et Edge)
$PagesAccueil = @(
  "https://scratch.mit.edu/projects/editor/",
  "https://www.tinkercad.com",
  "https://www.tictaclab.org",
  "https://editor.p5js.org"
)

# Favoris imposés (dossier "Tic Tac Lab" dans la barre de favoris)
$Favoris = [ordered]@{
  "Scratch"       = "https://scratch.mit.edu/projects/editor/"
  "Tinkercad"     = "https://www.tinkercad.com"
  "p5.js"         = "https://editor.p5js.org"
  "LEGO SPIKE"    = "https://spike.legoeducation.com"
  "Pybricks"      = "https://code.pybricks.com"
  "Open Roberta"  = "https://lab.open-roberta.org"
  "Mecabricks"    = "https://www.mecabricks.com"
  "Tic Tac Lab"   = "https://www.tictaclab.org"
}

# Logiciels winget (identifiant exact). Mettre un # devant une ligne pour l'exclure.
$Logiciels = @(
  "Mozilla.Firefox.fr"
  "Google.Chrome"
  "TheDocumentFoundation.LibreOffice"
  "Inkscape.Inkscape"
  "Bambulab.Bambustudio"
  "Ultimaker.Cura"
  "FreeCAD.FreeCAD"
  "BlenderFoundation.Blender"
  "BrickLink.Studio"
  "ArduinoSA.IDE.stable"
  "Microsoft.VisualStudioCode"
  "Git.Git"
  "Python.Python.3.13"
  "AivarAnnamaa.Thonny"
  "Audacity.Audacity"
  "OpenShot.OpenShot"
  "7zip.7zip"
)
$LogicielsLaser = @("LightBurnSoftware.LightBurn")
$LogicielsDell  = @("Dell.CommandUpdate.Universal")

$Log = "C:\TicTacLab\config.log"

# ----------------------------------------------------------------------------
#  Outils
# ----------------------------------------------------------------------------
$Alertes = New-Object System.Collections.Generic.List[string]
New-Item -ItemType Directory -Force -Path (Split-Path $Log) | Out-Null
function Ecrire($t, $couleur = "Gray") { Write-Host $t -ForegroundColor $couleur; Add-Content -Path $Log -Value "$(Get-Date -Format 'HH:mm:ss') $t" }
function OK($t)     { Ecrire "[OK] $t" "Green" }
function Info($t)   { Ecrire "[..] $t" "Cyan" }
function Alerte($t) { Ecrire "[!!] $t" "Yellow"; $Alertes.Add($t) }

$estAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $estAdmin) { Write-Host "Lance ce script en administrateur (double-clic sur lancer.cmd)." -ForegroundColor Red; exit 1 }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "winget est introuvable. Ouvre le Microsoft Store, mets à jour 'Programme d'installation d'application' puis relance." -ForegroundColor Red
  exit 1
}

function Installer-Winget($id) {
  # Déjà installé ?
  winget list --id $id --exact --accept-source-agreements --disable-interactivity *> $null
  if ($LASTEXITCODE -eq 0) { OK "$id (déjà installé)"; return }
  Info "Installation de $id..."
  $base = @("install","--id",$id,"--exact","--silent","--accept-package-agreements","--accept-source-agreements","--disable-interactivity")
  # D'abord pour tous les utilisateurs, sinon installation par défaut
  $sortie = winget @base --scope machine 2>&1; $code = $LASTEXITCODE
  if ($code -ne 0) { $sortie = winget @base 2>&1; $code = $LASTEXITCODE }
  $sortie | Out-String | Add-Content -Path $Log
  $LASTEXITCODE = $code
  if ($LASTEXITCODE -eq 0) { OK $id } else { Alerte "$id : échec (code $LASTEXITCODE). Vérifier avec : winget search $id" }
}

function Set-Reg($chemin, $nom, $valeur, $type = "String") {
  if (-not (Test-Path $chemin)) { New-Item -Path $chemin -Force | Out-Null }
  New-ItemProperty -Path $chemin -Name $nom -Value $valeur -PropertyType $type -Force | Out-Null
}

Ecrire "===== Début de la configuration : $(Get-Date) =====" "White"

# ----------------------------------------------------------------------------
#  1. Logiciels
# ----------------------------------------------------------------------------
Info "Mise à jour des sources winget..."
winget source update 2>&1 | Out-String | Add-Content -Path $Log

$liste = @($Logiciels)
if ($Laser)       { $liste += $LogicielsLaser }
if (-not $SansDell) { $liste += $LogicielsDell }
foreach ($id in $liste) { Installer-Winget $id }

# ----------------------------------------------------------------------------
#  2. Mises à jour Dell (BIOS, pilotes)
# ----------------------------------------------------------------------------
if (-not $SansDell) {
  $dcu = @("C:\Program Files\Dell\CommandUpdate\dcu-cli.exe","C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if ($dcu) {
    Info "Mises à jour Dell (BIOS et pilotes) - peut prendre 10-20 min..."
    $sortie = & $dcu /applyUpdates -silent -reboot=disable 2>&1; $code = $LASTEXITCODE
    $sortie | Out-String | Add-Content -Path $Log; $LASTEXITCODE = $code
    # 0 = ok, 1 = redémarrage requis, 500 = rien à faire
    if ($LASTEXITCODE -in 0,1,500) { OK "Mises à jour Dell (code $LASTEXITCODE ; 1 = redémarrer pour finir)" } else { Alerte "Dell Command Update : code $LASTEXITCODE" }
  } else { Alerte "Dell Command Update introuvable, mises à jour Dell sautées" }
}

# ----------------------------------------------------------------------------
#  3. Comptes : élève (standard) et administrateur
# ----------------------------------------------------------------------------
$grpUsers  = (Get-LocalGroup -SID "S-1-5-32-545").Name   # "Utilisateurs", quelle que soit la langue
$grpAdmins = (Get-LocalGroup -SID "S-1-5-32-544").Name   # "Administrateurs"
if ($EleveNom -eq "") { if ($NomPC -ne "") { $EleveNom = $NomPC } else { $EleveNom = $env:COMPUTERNAME.ToLower() } }
if ($NomPC -ne "" -and $EleveUser -ieq $NomPC) { Alerte "Le compte '$EleveUser' porte le même nom que la machine : ça marche, mais ça peut gêner le partage réseau." }

# Administrateur d'abord (pour ne jamais se retrouver sans compte admin)
$mdpAdmin = $null
if ($AdminMdp -ne "") { $mdpAdmin = ConvertTo-SecureString $AdminMdp -AsPlainText -Force }
if (-not (Get-LocalUser -Name $AdminUser -ErrorAction SilentlyContinue) -and $AncienAdmin -ne "" -and (Get-LocalUser -Name $AncienAdmin -ErrorAction SilentlyContinue)) {
  Rename-LocalUser -Name $AncienAdmin -NewName $AdminUser
  Set-LocalUser -Name $AdminUser -FullName "Admin Tic Tac Lab"
  OK "Compte '$AncienAdmin' renommé en '$AdminUser' (même mot de passe)"
}
if (Get-LocalUser -Name $AdminUser -ErrorAction SilentlyContinue) {
  if ($mdpAdmin) { Set-LocalUser -Name $AdminUser -Password $mdpAdmin -PasswordNeverExpires $true; OK "Mot de passe du compte '$AdminUser' mis à jour" }
} elseif ($mdpAdmin) {
  New-LocalUser -Name $AdminUser -FullName "Admin Tic Tac Lab" -Password $mdpAdmin -PasswordNeverExpires | Out-Null
  OK "Compte administrateur '$AdminUser' créé"
} else {
  Alerte "Compte admin '$AdminUser' introuvable et pas de mot de passe dans les réglages : vérifier le nom du compte admin"
}
if (Get-LocalUser -Name $AdminUser -ErrorAction SilentlyContinue) {
  Add-LocalGroupMember -Group $grpAdmins -Member $AdminUser -ErrorAction SilentlyContinue
}

# Élève : on reprend l'ancien compte "eleve" s'il existe (premier essai du script)
$mdp = ConvertTo-SecureString $EleveMdp -AsPlainText -Force
if (-not (Get-LocalUser -Name $EleveUser -ErrorAction SilentlyContinue) -and (Get-LocalUser -Name "eleve" -ErrorAction SilentlyContinue) -and $EleveUser -ne "eleve") {
  Rename-LocalUser -Name "eleve" -NewName $EleveUser
  OK "Ancien compte 'eleve' renommé en '$EleveUser'"
}
if (-not (Get-LocalUser -Name $EleveUser -ErrorAction SilentlyContinue)) {
  New-LocalUser -Name $EleveUser -FullName $EleveNom -Password $mdp -PasswordNeverExpires -UserMayNotChangePassword | Out-Null
  OK "Compte '$EleveUser' créé (affiché : $EleveNom)"
} else {
  Set-LocalUser -Name $EleveUser -FullName $EleveNom -Password $mdp -PasswordNeverExpires $true -UserMayChangePassword $false
  OK "Compte '$EleveUser' mis à jour (affiché : $EleveNom)"
}
Add-LocalGroupMember -Group $grpUsers -Member $EleveUser -ErrorAction SilentlyContinue
# Jamais administrateur
if (Get-LocalGroupMember -Group $grpAdmins -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*\$EleveUser" }) {
  Remove-LocalGroupMember -Group $grpAdmins -Member $EleveUser
  OK "'$EleveUser' retiré des administrateurs"
}
OK "'$EleveUser' est un compte standard : le mot de passe de '$AdminUser' sera demandé pour les actions admin"

# Masquer le compte admin de l'écran de connexion (optionnel)
$ul = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList"
if ($MasquerAdmin) { Set-Reg $ul $AdminUser 0 "DWord"; OK "Compte '$AdminUser' masqué à l'écran de connexion" }
elseif (Test-Path $ul) { Remove-ItemProperty -Path $ul -Name $AdminUser -ErrorAction SilentlyContinue }

if ($AutoLogin) {
  $wl = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
  Set-Reg $wl "AutoAdminLogon" "1"
  Set-Reg $wl "DefaultUserName" $EleveUser
  Set-Reg $wl "DefaultPassword" $EleveMdp
  Set-Reg $wl "DefaultDomainName" $env:COMPUTERNAME
  OK "Ouverture de session automatique : $EleveUser"
}

# ----------------------------------------------------------------------------
#  4. Firefox : pages d'accueil + favoris (policies.json)
# ----------------------------------------------------------------------------
$ffDir = "C:\Program Files\Mozilla Firefox"
if (Test-Path $ffDir) {
  $fav = @(@{ toplevel_name = "Tic Tac Lab" })
  foreach ($k in $Favoris.Keys) { $fav += @{ name = $k; url = $Favoris[$k] } }
  $pol = @{
    policies = @{
      Homepage = @{ URL = $PagesAccueil[0]; Additional = @($PagesAccueil | Select-Object -Skip 1); StartPage = "homepage"; Locked = $false }
      ManagedBookmarks = $fav
      DisplayBookmarksToolbar = "always"
      DisableTelemetry = $true
      DontCheckDefaultBrowser = $true
      OverrideFirstRunPage = ""
      OverridePostUpdatePage = ""
      NoDefaultBookmarks = $true
    }
  }
  New-Item -ItemType Directory -Force -Path "$ffDir\distribution" | Out-Null
  $json = $pol | ConvertTo-Json -Depth 6
  [IO.File]::WriteAllText("$ffDir\distribution\policies.json", $json, (New-Object Text.UTF8Encoding($false)))
  OK "Firefox : onglets d'accueil et favoris"
} else { Alerte "Firefox non trouvé : configuration Firefox sautée" }

# ----------------------------------------------------------------------------
#  5. Chrome et Edge : pages d'accueil + favoris (stratégies registre)
# ----------------------------------------------------------------------------
$favChrome = @(@{ toplevel_name = "Tic Tac Lab" })
foreach ($k in $Favoris.Keys) { $favChrome += @{ name = $k; url = $Favoris[$k] } }
$favJson = $favChrome | ConvertTo-Json -Compress -Depth 4

foreach ($nav in @("HKLM:\SOFTWARE\Policies\Google\Chrome", "HKLM:\SOFTWARE\Policies\Microsoft\Edge")) {
  Set-Reg $nav "RestoreOnStartup" 4 "DWord"
  if (Test-Path "$nav\RestoreOnStartupURLs") { Remove-Item "$nav\RestoreOnStartupURLs" -Recurse -Force }
  $i = 1; foreach ($u in $PagesAccueil) { Set-Reg "$nav\RestoreOnStartupURLs" "$i" $u; $i++ }
  Set-Reg $nav "ManagedBookmarks" $favJson
  Set-Reg $nav "BookmarkBarEnabled" 1 "DWord"
  Set-Reg $nav "MetricsReportingEnabled" 0 "DWord"
  Set-Reg $nav "PromotionalTabsEnabled" 0 "DWord"
  Set-Reg $nav "DefaultBrowserSettingEnabled" 0 "DWord"
}
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Edge" "HideFirstRunExperience" 1 "DWord"
OK "Chrome et Edge : onglets d'accueil et favoris"

# ----------------------------------------------------------------------------
#  6. Petits réglages Windows
# ----------------------------------------------------------------------------
# Pas de suggestions d'applis / publicités dans le menu Démarrer (tous les comptes)
Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1 "DWord"
# Afficher les extensions de fichiers pour les nouveaux comptes (profil par défaut)
reg load HKU\DefaultTTL "C:\Users\Default\NTUSER.DAT" *> $null
if ($LASTEXITCODE -eq 0) {
  reg add "HKU\DefaultTTL\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f *> $null
  [gc]::Collect(); Start-Sleep 1
  reg unload HKU\DefaultTTL *> $null
}
OK "Réglages Windows (pas de pubs Démarrer, extensions visibles)"

# ----------------------------------------------------------------------------
#  7. Nom de la machine
# ----------------------------------------------------------------------------
$redemarrer = $false
if ($NomPC -ne "") {
  if ($NomPC -notmatch '^[A-Za-z0-9-]{1,15}$') { Alerte "Nom '$NomPC' invalide (15 caractères max, lettres, chiffres, tirets)" }
  elseif ($env:COMPUTERNAME -ieq $NomPC) { OK "Nom déjà '$NomPC'" }
  else { Rename-Computer -NewName $NomPC -Force -ErrorAction SilentlyContinue; if ($?) { OK "Renommé en $NomPC (après redémarrage)"; $redemarrer = $true } else { Alerte "Renommage en $NomPC : échec" } }
}

# ----------------------------------------------------------------------------
#  Bilan
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "==============================================================="
if ($Alertes.Count -gt 0) {
  Write-Host "Terminé AVEC $($Alertes.Count) alerte(s) :" -ForegroundColor Yellow
  $Alertes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
  Write-Host "Relance le script pour réessayer (il saute ce qui est déjà fait)."
} else {
  Write-Host "Terminé sans erreur." -ForegroundColor Green
}
Write-Host "Journal complet : $Log"
Write-Host "Redémarre le PC, puis fais les tests de la fiche (étape 3)."
Write-Host "==============================================================="
