#!/usr/bin/env bash
# Remet la télé dans son état d'origine.
# Usage : ./restaurer.sh IP_TELE [dossier-sauvegarde]
set -u
TV="${1:?Usage: $0 IP_TELE [dossier-sauvegarde]}"
DIR="${2:-$(ls -d sauvegarde-* 2>/dev/null | sort | tail -1)}"

echo "== 1/3 Désinstallation de l'appli « Accueil » (la seule chose installée) =="
if command -v sdb >/dev/null 2>&1; then
  sdb connect "$TV:26101" >/dev/null 2>&1 || true
  if command -v tizen >/dev/null 2>&1; then
    TARGET="$(sdb devices | awk -v t="$TV:26101" '$1==t {print $3}')"
    tizen uninstall -p AcclMinHm.Accueil -t "$TARGET" || true
  else
    sdb -s "$TV:26101" shell 0 vd_appuninstall AcclMinHm || true
  fi
else
  echo "  sdb absent : sur la télé, Applis > Accueil > appui long > Supprimer."
fi

echo
echo "== 2/3 Réglages à remettre à la main (valeurs notées avant modification) =="
if [ -n "$DIR" ] && [ -f "$DIR/reglages-avant.txt" ]; then
  cat "$DIR/reglages-avant.txt"
else
  echo "  Sauvegarde introuvable. Valeurs d'usine : tout activé, DNS automatique."
fi
echo "  Réinitialisation totale possible : Paramètres > Assistance > Entretien > Réinitialiser"
echo "  (efface aussi tes comptes et applis : en dernier recours seulement)."

echo
echo "== 3/3 Mode développeur =="
echo "  Applis > taper 1 2 3 4 5 > Mode développeur : Désactivé, puis redémarrer la télé."

if [ -n "$DIR" ] && [ -f "$DIR/appareil.json" ]; then
  echo; echo "Vérification : état actuel comparé à la sauvegarde"
  curl -s --max-time 5 "http://$TV:8001/api/v2/" > /tmp/appareil-maintenant.json || true
  diff <(tr ',' '\n' < "$DIR/appareil.json") <(tr ',' '\n' < /tmp/appareil-maintenant.json) \
    && echo "  Identique." || echo "  (différences ci-dessus : normal si le firmware a changé)"
fi
