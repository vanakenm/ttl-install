# Configuration des laptops Techies – logiciels et réglages

Nov 26, 2026 · @Martin Van Aken

Cette fiche décrit ce que contient chaque laptop après le script `config-tictaclab.ps1`. Pour modifier un élément, change la partie RÉGLAGES du script, puis relance-le.

## Logiciels installés par le script

Le script installe 18 logiciels avec winget, plus LightBurn sur le PC de la découpeuse laser. L'identifiant winget sert à retrouver un logiciel avec `winget search` ou à le mettre à jour.

| Domaine | Logiciel | Usage | Identifiant winget |
| --- | --- | --- | --- |
| Navigation | Firefox (français) | Navigateur principal | `Mozilla.Firefox.fr` |
| Navigation | Google Chrome | Robots dans le navigateur (SPIKE, Pybricks) | `Google.Chrome` |
| Bureautique | LibreOffice | Textes, tableurs, présentations | `TheDocumentFoundation.LibreOffice` |
| Bureautique | 7-Zip | Ouvrir les archives .zip et .7z | `7zip.7zip` |
| Fablab | Inkscape | Dessin vectoriel, fichiers pour la laser | `Inkscape.Inkscape` |
| Fablab | Bambu Studio | Préparer les impressions 3D Bambu | `Bambulab.Bambustudio` |
| Fablab | Cura | Préparer les impressions 3D (autres imprimantes) | `Ultimaker.Cura` |
| Fablab | FreeCAD | Modélisation 3D technique | `FreeCAD.FreeCAD` |
| Fablab | Blender | Modélisation et animation 3D | `BlenderFoundation.Blender` |
| Fablab | LightBurn (PC laser seulement) | Piloter la découpeuse laser | `LightBurnSoftware.LightBurn` |
| Robots | BrickLink Studio | Construire en LEGO virtuel | `BrickLink.Studio` |
| Programmation | Arduino IDE | Programmer les cartes Arduino | `ArduinoSA.IDE.stable` |
| Programmation | Thonny | Python pour débutants | `AivarAnnamaa.Thonny` |
| Programmation | Python 3.13 | Langage Python | `Python.Python.3.13` |
| Programmation | VS Code | Éditeur de code | `Microsoft.VisualStudioCode` |
| Programmation | Git | Gestion de versions, GitHub | `Git.Git` |
| Multimédia | Audacity | Enregistrer et monter du son | `Audacity.Audacity` |
| Multimédia | OpenShot | Montage vidéo | `OpenShot.OpenShot` |
| Système | Dell Command Update | Mises à jour du BIOS et des pilotes Dell | `Dell.CommandUpdate.Universal` |

LightBurn s'installe avec l'option `-Laser` : `lancer.cmd techies01 -Laser`. Il demande une licence après la période d'essai.

## Applis à installer à la main et outils en ligne

Deux applis viennent du Microsoft Store. Le Store les installe compte par compte : il faut donc les installer depuis la session `techies`, sans compte Microsoft.

| Appli | Usage | Où la trouver |
| --- | --- | --- |
| LEGO Education SPIKE | Programmer les robots SPIKE Prime et Essential | Microsoft Store |
| Robo Wunderkind | Programmer les robots Robo Wunderkind | Microsoft Store |
| EV3 Classroom | Programmer les robots EV3 | Plus téléchargeable depuis le 31 juillet 2026 : voir la page des produits retirés de LEGO Education |

Les autres outils s'utilisent dans le navigateur, sans installation. Ils sont tous dans le dossier de favoris « Tic Tac Lab ».

| Outil | Usage | Adresse |
| --- | --- | --- |
| Scratch | Programmation en blocs | scratch.mit.edu |
| Tinkercad | 3D et électronique pour débutants | tinkercad.com |
| p5.js | Code créatif en JavaScript | editor.p5js.org |
| LEGO SPIKE (web) | SPIKE sans installer l'appli, dans Chrome | spike.legoeducation.com |
| Pybricks | Python pour robots LEGO, dont EV3, dans Chrome | code.pybricks.com |
| Open Roberta | Programmation en blocs pour EV3 et d'autres robots | lab.open-roberta.org |
| Mecabricks | Construction LEGO en ligne | mecabricks.com |

## Comptes et nom des machines

Chaque laptop a deux comptes : celui des enfants, et un compte administrateur qui sert uniquement quand Windows demande une autorisation.

| Compte | Nom de connexion | Mot de passe | Droits | Remarque |
| --- | --- | --- | --- | --- |
| Enfants | `techies` | `codingrobot` | Standard : pas d'installation, pas de réglage protégé | Affiché sous le nom de la machine, par exemple « techies13 » |
| Administrateur | `ttl-admin` | Choisi sur chaque machine, pas dans le script | Administrateur | Peut être masqué de l'écran de connexion (`$MasquerAdmin = $true`) |

- **Nom des machines :** `techies` suivi du numéro, à partir de `techies13` (les 12 premiers existent déjà). Il est donné au lancement : `lancer.cmd techies13`.
- **Compte admin d'origine :** le compte `ttl-u01` créé à la première configuration est renommé en `ttl-admin` et garde son mot de passe. Change ce mot de passe ensuite sur la machine : **Ctrl+Alt+Suppr**, puis **Modifier un mot de passe**.
- **Action admin depuis la session des enfants :** Windows ouvre une fenêtre d'autorisation. On y tape `ttl-admin` et son mot de passe, sans changer de session.
- **Licence Windows :** chaque laptop a sa propre clé Windows, enregistrée dans sa carte mère. Elle ne peut pas servir sur une autre machine.

## Navigateurs : onglets d'accueil et favoris

Firefox, Chrome et Edge ont exactement les mêmes réglages. Ils sont imposés par des « stratégies » Windows et s'appliquent à tous les comptes.

**Onglets ouverts au démarrage**

1. Scratch – scratch.mit.edu/projects/editor
2. Tinkercad – tinkercad.com
3. Tic Tac Lab – tictaclab.org
4. p5.js – editor.p5js.org

**Dossier de favoris « Tic Tac Lab »**, toujours visible dans la barre de favoris : Scratch, Tinkercad, p5.js, LEGO SPIKE, Pybricks, Open Roberta, Mecabricks, Tic Tac Lab.

**Autres réglages**

- Pas d'envoi de statistiques d'utilisation à Mozilla, Google ou Microsoft.
- Pas de page d'accueil « premier lancement » ni d'onglets promotionnels.
- Les navigateurs ne demandent pas à devenir le navigateur par défaut. Il se choisit à la main : je conseille Chrome, qui se connecte aux robots en USB et en Bluetooth.

## Réglages Windows et entretien

**Réglages appliqués par le script**

- Pas de suggestions d'applis ni de publicités dans le menu Démarrer.
- Extensions de fichiers visibles (.svg, .stl, .ino…) pour les nouveaux comptes.
- Pilotes et BIOS Dell mis à jour avec Dell Command Update.
- Ouverture de session automatique désactivée : il faut taper `codingrobot`. Réglage `$AutoLogin`.

**Entretien**

- **Windows Update :** automatique.
- **Logiciels :** une fois par mois, depuis une invite de commandes ouverte en administrateur, lancer `winget upgrade --all`.
- **Applis du Store (SPIKE, Robo Wunderkind) :** mises à jour par le Store.
- **Ajouter un logiciel sur toutes les machines :** ajoute son identifiant winget dans la liste `$Logiciels` du script, puis relance le script. Ce qui est déjà installé est sauté.

**Fichiers du script**, dans le projet Tic Tac Lab : `config-tictaclab.ps1` et `lancer.cmd`. Le journal de chaque installation se trouve dans `C:\TicTacLab\config.log` sur la machine.
