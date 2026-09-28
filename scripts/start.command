#!/bin/bash
# macOS : double-clic. Se place à la racine du projet puis délègue à start.sh (sans exiger son bit x).
cd "$(dirname "$0")/.." || { echo "Impossible de trouver le dossier du projet."; read -r _; exit 1; }
[ -f ./scripts/start.sh ] || { echo "Le fichier scripts/start.sh est introuvable : le projet est incomplet (GitHub Desktop → Pull). Appuyez sur Entrée pour fermer."; read -r _; exit 1; }
exec /bin/bash "./scripts/start.sh"
