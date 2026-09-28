@echo off
rem Lance l'editeur du site. Ne pas modifier. Les messages sont dans start.ps1.
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%~dp0start.ps1"
if errorlevel 1 (
  echo.
  echo Le lancement a echoue. Lisez le message ci-dessus, puis fermez cette fenetre.
  pause
)
