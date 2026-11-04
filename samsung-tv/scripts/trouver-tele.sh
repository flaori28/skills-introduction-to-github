#!/usr/bin/env bash
# Cherche les télés Samsung (Tizen) sur le réseau local.
# Elles répondent sur http://IP:8001/api/v2/ quand elles sont allumées.
# Usage : ./trouver-tele.sh [préfixe, ex. 192.168.1]
set -u
prefix="${1:-}"
if [ -z "$prefix" ]; then
  ip=$( (ip -4 route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}') \
        || true)
  [ -z "$ip" ] && ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
  [ -z "$ip" ] && { echo "Impossible de trouver ton IP : passe le préfixe en argument (ex. 192.168.1)"; exit 1; }
  prefix="${ip%.*}"
fi
echo "Recherche sur $prefix.1-254 (la télé doit être allumée)…"
for i in $(seq 1 254); do
  (
    out=$(curl -s --max-time 1 "http://$prefix.$i:8001/api/v2/" 2>/dev/null)
    if echo "$out" | grep -q '"device"'; then
      name=$(echo "$out" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p' | head -1)
      model=$(echo "$out" | sed -n 's/.*"modelName":"\([^"]*\)".*/\1/p' | head -1)
      dev=$(echo "$out" | sed -n 's/.*"developerMode":"\([^"]*\)".*/\1/p' | head -1)
      echo "  -> $prefix.$i  nom=\"$name\"  modèle=$model  mode développeur=${dev:-?}"
    fi
  ) &
done
wait
echo "Terminé."
