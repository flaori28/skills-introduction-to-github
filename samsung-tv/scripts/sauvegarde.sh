#!/usr/bin/env bash
# Sauvegarde l'état de la télé AVANT toute modification.
# Usage : ./sauvegarde.sh IP_TELE
set -eu
TV="${1:?Usage: $0 IP_TELE}"
DIR="sauvegarde-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DIR"
echo "Sauvegarde dans $DIR/"

# 1. Infos de l'appareil (modèle, firmware, mode développeur…)
curl -s --max-time 5 "http://$TV:8001/api/v2/" > "$DIR/appareil.json" \
  && echo "  appareil.json OK" || echo "  ! télé injoignable sur $TV:8001"

# 2. État des applis du dock (installée / version)
for id in 3201907018807 11101200001 111299001912 3201910019365 3201512006785 3201901017640; do
  printf '%s ' "$id"; curl -s --max-time 5 "http://$TV:8001/api/v2/applications/$id"; echo
done > "$DIR/applis-dock.txt"
echo "  applis-dock.txt OK"

# 3. Liste complète des applis installées (nécessite sdb + mode développeur)
if command -v sdb >/dev/null 2>&1; then
  sdb connect "$TV:26101" >/dev/null 2>&1 || true
  sdb -s "$TV:26101" shell 0 vd_applist > "$DIR/applis-installees.txt" 2>&1 || true
  sdb -s "$TV:26101" capability > "$DIR/sdb-capability.txt" 2>&1 || true
  echo "  applis-installees.txt (via sdb)"
else
  echo "  (sdb absent : liste complète des applis non sauvegardée, ce n'est pas bloquant)"
fi

# 4. Les réglages Tizen ne sont pas lisibles depuis l'extérieur : on les note à la main.
cat > "$DIR/reglages-avant.txt" <<'TXT'
Note la valeur ACTUELLE de chaque réglage AVANT de le changer
(prends aussi une photo de chaque écran avec ton téléphone).

[ ] Confidentialité > Informations de visionnage ............ : ________
[ ] Confidentialité > Publicités basées sur les intérêts ..... : ________
[ ] Confidentialité > Service de reconnaissance vocale ....... : ________
[ ] Conditions facultatives acceptées (marketing, TV Plus…) .. : ________
[ ] Fonctions Smart > Lancement auto du Smart Hub ............ : ________
[ ] Fonctions Smart > Lancer la dernière appli ............... : ________
[ ] Réseau > Paramètres IP > DNS (auto ou adresse) ........... : ________
[ ] Applis retirées de l'accueil (noms) ....................... : ________
TXT
echo "  reglages-avant.txt : à remplir à la main"
echo "Fini. Garde ce dossier : restaurer.sh s'en sert."
