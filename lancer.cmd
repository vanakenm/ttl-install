@echo off
rem Lance config-tictaclab.ps1 en administrateur.
rem Pour renommer la machine : lancer.cmd techies13
rem Pour le PC de la laser    : lancer.cmd techies01 -Laser
set NOM=%~1
set EXTRA=%~2
if "%NOM%"=="" (
  powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -File \"%~dp0config-tictaclab.ps1\" %EXTRA%'"
) else (
  powershell -NoProfile -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -NoExit -File \"%~dp0config-tictaclab.ps1\" -NomPC %NOM% %EXTRA%'"
)
