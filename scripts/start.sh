#!/bin/bash
set -u
PORT=1313
URL="http://127.0.0.1:$PORT/admin/"     # 127.0.0.1 (pas localhost -> ::1) ; /admin/ (index.html -> 301)

erreur() {
  echo ""; echo "ERREUR : $1" >&2
  echo "Si le problème persiste, demandez de l'aide en montrant cette fenêtre (voir AIDE.md). Appuyez sur Entrée pour fermer."; read -r _
  exit 1                                  # le trap EXIT (étape 5) arrête Hugo s'il a été lancé
}
# Occupé = quelque chose accepte la connexion, HTTP ou non. Seul curl exit 7 (« connexion refusée ») = libre ;
# tout autre code (0 = réponse HTTP, 1/52/56 = service non HTTP, 28 = délai) = quelque chose écoute.
# --max-time 3 (comme admin_pret) : sur macOS/Linux un port fermé refuse immédiatement, mais sous Windows le refus
# n'arrive qu'après ~2,1 s (observé le 2026-09-23) et un délai de 2 s le prendrait pour « occupé ».
port_occupe() { curl -s -o /dev/null --max-time 3 "http://127.0.0.1:$PORT/"; [ $? -ne 7 ]; }
# Prêt = Hugo sert réellement le CMS (200 sur /admin/) ; -f fait échouer curl sur 404 tant que le 1er build n'est pas fini
admin_pret()  { curl -sf -o /dev/null --max-time 3 "http://127.0.0.1:$PORT/admin/"; }
ouvrir_navigateur() {
  # SITE_SANS_NAVIGATEUR=1 (tests automatisés) : aucun navigateur, ni à l'étape 4 (« Le site tourne déjà ») ni à l'étape 7
  [ "${SITE_SANS_NAVIGATEUR:-}" = "1" ] && return 0
  if [ "$(uname -s)" = "Darwin" ]; then
    open -b com.google.Chrome "$1" 2>/dev/null || open -b com.microsoft.edgemac "$1" 2>/dev/null \
      || { open "$1"; echo "ATTENTION : Chrome ou Edge n'a pas été trouvé. Le navigateur par défaut a été ouvert, mais l'éditeur ne fonctionne qu'avec Chrome ou Edge."; }
  else
    for b in google-chrome google-chrome-stable microsoft-edge chromium chromium-browser; do
      if command -v "$b" >/dev/null 2>&1; then "$b" "$1" >/dev/null 2>&1 & return; fi
    done
    xdg-open "$1" >/dev/null 2>&1 &
    echo "ATTENTION : Chrome ou Edge n'a pas été trouvé. Le navigateur par défaut a été ouvert, mais l'éditeur ne fonctionne qu'avec Chrome ou Edge."
  fi
}

# 1. Racine
cd "$(dirname "$0")/.." || erreur "impossible de trouver le dossier du projet."
ROOT="$(pwd)"
[ -f .hugo-version ] || erreur "le fichier .hugo-version est introuvable."

# 2. Version
VER="$(tr -d '[:space:]' < .hugo-version)"
echo "$VER" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || erreur "le fichier .hugo-version est invalide (« $VER »)."
TOOLDIR="$ROOT/.tools/hugo-$VER"; HUGO="$TOOLDIR/hugo"

# 3. Téléchargement
if [ ! -x "$HUGO" ]; then
  OS="$(uname -s)"; M="$(uname -m)"
  case "$OS" in
    Darwin) ASSET="hugo_${VER}_darwin-universal.pkg"; SHA="shasum -a 256" ;;
    Linux)
      case "$M" in x86_64) A=amd64 ;; aarch64|arm64) A=arm64 ;; *) erreur "architecture non prise en charge : $M" ;; esac
      ASSET="hugo_${VER}_linux-$A.tar.gz"; SHA="sha256sum" ;;
    *) erreur "système non pris en charge : $OS" ;;
  esac
  SUMS="hugo_${VER}_checksums.txt"
  BASE="https://github.com/gohugoio/hugo/releases/download/v$VER"
  mkdir -p "$ROOT/.tools"
  TMP="$(mktemp -d "$ROOT/.tools/tmp.XXXXXX")" || erreur "impossible de créer un dossier temporaire."
  trap 'rm -rf "$TMP"' EXIT

  echo "Téléchargement d'Hugo $VER (une seule fois, environ 20 Mo)…"
  curl -fsSL --retry 3 -o "$TMP/$ASSET" "$BASE/$ASSET" || erreur "téléchargement impossible. Vérifiez votre connexion Internet, puis relancez."
  curl -fsSL --retry 3 -o "$TMP/$SUMS"  "$BASE/$SUMS"  || erreur "téléchargement impossible (fichier de contrôle). Vérifiez votre connexion Internet, puis relancez."

  echo "Vérification du fichier téléchargé…"
  LINE="$(grep "  ${ASSET}\$" "$TMP/$SUMS")"
  [ "$(printf '%s\n' "$LINE" | grep -c .)" -eq 1 ] || erreur "le fichier de contrôle ne mentionne pas $ASSET."
  [ "${LINE##*  }" = "$ASSET" ] || erreur "le fichier de contrôle ne mentionne pas $ASSET."   # les « . » du motif grep ne sont pas échappés : comparaison exacte du nom (bash 3.2)
  ( cd "$TMP" && printf '%s\n' "$LINE" | $SHA -c - >/dev/null 2>&1 ) \
    || erreur "le fichier téléchargé est corrompu ou modifié (empreinte différente). Il a été supprimé : relancez le script."

  echo "Installation dans .tools…"
  mkdir -p "$TOOLDIR"
  if [ "$OS" = "Darwin" ]; then
    # Pas d'installation système : le pkg exigerait le mot de passe admin et écrirait /usr/local/bin.
    rm -rf "$TMP/expanded"                                    # pkgutil exige un dossier NOUVEAU
    if pkgutil --expand-full "$TMP/$ASSET" "$TMP/expanded" 2>/dev/null && [ -f "$TMP/expanded/Payload/hugo" ]; then
      mv "$TMP/expanded/Payload/hugo" "$HUGO"
    else
      # Repli : xar + cpio (outils système) ; le cpio contient ./hugo et ./._hugo
      mkdir -p "$TMP/x" \
        && ( cd "$TMP/x" && xar -xf "$TMP/$ASSET" && gunzip -c Payload | cpio -id 2>/dev/null ) \
        && [ -f "$TMP/x/hugo" ] && mv "$TMP/x/hugo" "$HUGO" \
        || erreur "impossible d'installer Hugo (extraction du paquet macOS)."
    fi
  else
    tar -xzf "$TMP/$ASSET" -C "$TOOLDIR" hugo || erreur "impossible d'installer Hugo (extraction)."
  fi
  chmod +x "$HUGO"
  xattr -d com.apple.quarantine "$HUGO" 2>/dev/null || true   # sans effet si aucune quarantaine (curl n'en pose pas)
  "$HUGO" version 2>/dev/null | grep -q "^hugo v$VER" || erreur "la version installée ne correspond pas : $("$HUGO" version 2>&1)"
  rm -rf "$TMP"; trap - EXIT
  echo "Hugo $VER installé dans .tools/hugo-$VER/"
fi

# 4. Port
if port_occupe; then
  if admin_pret; then          # /admin/ -> 200 ; (/admin/index.html donnerait 301, que curl sans -L ne suit pas)
    echo "Le site tourne déjà (une autre fenêtre de lancement est ouverte). Ouverture de l'éditeur…"
    ouvrir_navigateur "$URL"; sleep 2; exit 0
  fi
  erreur "le port $PORT est déjà utilisé par un autre programme. Fermez-le (ou l'autre fenêtre de lancement), puis relancez."
fi

# 5. Hugo
echo "Démarrage du site…"
"$HUGO" server --bind 127.0.0.1 --port "$PORT" --buildDrafts --environment development &
PID=$!
trap 'kill "$PID" 2>/dev/null' EXIT INT TERM       # toute sortie (erreur, timeout, fermeture) arrête Hugo

# 6. Attente : HTTP 200 sur /admin/ (Hugo ouvre le port avant la fin du 1er build ; un simple test TCP serait trop tôt)
i=0
until admin_pret; do
  if ! kill -0 "$PID" 2>/dev/null; then
    sleep 0.3
    # Hugo mort ET port écouté = « bind: address already in use » : ce n'est pas une erreur de contenu
    port_occupe && erreur "le port $PORT est déjà utilisé par un autre programme. Fermez-le (ou l'autre fenêtre de lancement), puis relancez."
    erreur "Hugo s'est arrêté tout de suite. Lisez le message ci-dessus : c'est souvent une erreur dans un article."
  fi
  i=$((i+1)); [ "$i" -gt 200 ] && erreur "le site ne répond pas après 60 secondes."
  sleep 0.3
done

# 7. Navigateur (SITE_SANS_NAVIGATEUR=1 : aucun navigateur n'est ouvert — garde dans ouvrir_navigateur, pour les tests automatisés)
ouvrir_navigateur "$URL"

# 8. Récapitulatif
echo ""; echo "  Site         : http://127.0.0.1:$PORT/"
echo "  Édition      : $URL"
echo "  Pour arrêter : fermez simplement cette fenêtre."; echo ""

# 9. Attente
wait "$PID"
