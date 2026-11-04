#!/usr/bin/env bash
# Construit, signe et installe l'appli « Accueil » sur la télé.
# Prérequis :
#  - Tizen Studio + extension « Samsung TV » (fournit les commandes tizen et sdb)
#  - un profil de certificat Samsung créé dans Certificate Manager (nom passé en 2e argument)
#  - télé en mode développeur avec l'IP de ton ordinateur (Apps > taper 1 2 3 4 5)
# Usage : ./installer.sh IP_TELE NOM_PROFIL_CERTIFICAT
set -eu
TV="${1:?Usage: $0 IP_TELE PROFIL}"; PROFILE="${2:?Usage: $0 IP_TELE PROFIL}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
for c in tizen sdb; do command -v $c >/dev/null || { echo "Commande $c introuvable (installe Tizen Studio)"; exit 1; }; done

ls -d sauvegarde-* >/dev/null 2>&1 || { echo "Lance d'abord ./sauvegarde.sh $TV"; exit 1; }

BUILD="$(mktemp -d)"
cp -R "$HERE/home-app/." "$BUILD/"
( cd "$BUILD" && tizen package -t wgt -s "$PROFILE" -- "$BUILD" )
WGT="$(ls "$BUILD"/*.wgt | head -1)"

sdb connect "$TV:26101"
TARGET="$(sdb devices | awk -v t="$TV:26101" '$1==t {print $3}')"
tizen install -n "$WGT" -t "$TARGET"
tizen run -p AcclMinHm.Accueil -t "$TARGET"
echo "Installée et lancée. Vérifie à l'écran (photo), puis épingle « Accueil »"
echo "en 1re position de la barre Smart Hub (appui long > Déplacer)."
