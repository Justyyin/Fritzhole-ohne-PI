#!/usr/bin/env bash
#
# test-dnsfilter.sh
#
# Checks whether the DNS filter of a FRITZ!Box is active.
# Prüft, ob der DNS-Filter einer FRITZ!Box aktiv ist.
#
# Usage / Aufruf:
#   ./test-dnsfilter.sh [-s DNS_SERVER] [-l LIST_URL] [-n COUNT] [--lang de|en]
#
# Exit codes:
#   0  filter active / Filter aktiv
#   1  filter partially or not active / Filter teilweise oder nicht aktiv
#   2  usage or environment error / Aufruf- oder Umgebungsfehler
#
# SPDX-License-Identifier: MIT

set -u

DNS_SERVER="192.168.178.1"
LIST_URL="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt"
COUNT=5
CONTROL_DOMAINS=("wikipedia.org" "fritz.com")

case "${LANG:-}${LC_ALL:-}" in
  *de_*|*de-*) UI_LANG="de" ;;
  *)           UI_LANG="en" ;;
esac

usage() {
  sed -n '3,15p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    -s|--server) DNS_SERVER="${2:?}"; shift 2 ;;
    -l|--list)   LIST_URL="${2:?}"; shift 2 ;;
    -n|--count)  COUNT="${2:?}"; shift 2 ;;
    --lang)      UI_LANG="${2:?}"; shift 2 ;;
    -h|--help)   usage ;;
    *)           usage ;;
  esac
done

msg() {
  local key="$1"; shift
  local de en
  case "$key" in
    missing)   de="Benötigtes Programm fehlt: %s";                         en="Required program missing: %s" ;;
    server)    de="DNS-Server : %s";                                      en="DNS server : %s" ;;
    list)      de="Filterliste: %s";                                      en="Filter list: %s" ;;
    nolist)    de="Aus der Filterliste konnten keine Testdomains gelesen werden."; en="Could not read test domains from the filter list." ;;
    hblock)    de="Erwartet: blockiert";                                  en="Expected: blocked" ;;
    hallow)    de="Erwartet: erreichbar (Gegenprobe)";                    en="Expected: reachable (cross-check)" ;;
    noanswer)  de="keine Antwort";                                        en="no answer" ;;
    r_ok)      de="Ergebnis: DNS-Filter aktiv (%s/%s blockiert).";        en="Result: DNS filter active (%s/%s blocked)." ;;
    r_part)    de="Ergebnis: teilweise aktiv (%s/%s). Filterlisten in der FRITZ!Box aktualisieren."; en="Result: partially active (%s/%s). Update the filter lists in the FRITZ!Box." ;;
    r_none)    de="Ergebnis: nicht aktiv. Siehe README, Abschnitt Fehlerbehebung."; en="Result: not active. See README, section Troubleshooting." ;;
    r_ctrl)    de="Warnung: Die Gegenprobe ist fehlgeschlagen. Normale Domains werden nicht aufgelöst."; en="Warning: cross-check failed. Regular domains are not resolved." ;;
  esac
  if [ "$UI_LANG" = "de" ]; then printf "$de\n" "$@"; else printf "$en\n" "$@"; fi
}

for bin in curl nslookup; do
  command -v "$bin" >/dev/null 2>&1 || { msg missing "$bin"; exit 2; }
done

msg server "$DNS_SERVER"
msg list "$LIST_URL"
echo

DOMAINS=()
while IFS= read -r line; do
  DOMAINS+=("$line")
done < <(curl -fsSL --max-time 30 "$LIST_URL" | grep -vE '^[[:space:]]*(#|!|$)' | sed 's/^\*\.//' | head -n "$COUNT")

if [ "${#DOMAINS[@]}" -eq 0 ]; then
  msg nolist
  exit 2
fi

resolve() {
  nslookup "$1" "$DNS_SERVER" 2>/dev/null \
    | awk '/^Name:/ {found=1} found && /^Address/ {print $NF; exit}'
}

blocked=0
msg hblock
for d in "${DOMAINS[@]}"; do
  ip="$(resolve "$d")"
  if [ -z "$ip" ] || [ "$ip" = "0.0.0.0" ] || [ "$ip" = "::" ]; then
    printf "  [ OK ] %-48s %s\n" "$d" "${ip:-$(msg noanswer)}"
    blocked=$((blocked + 1))
  else
    printf "  [FAIL] %-48s %s\n" "$d" "$ip"
  fi
done

echo
msg hallow
control_ok=1
for d in "${CONTROL_DOMAINS[@]}"; do
  ip="$(resolve "$d")"
  if [ -n "$ip" ] && [ "$ip" != "0.0.0.0" ]; then
    printf "  [ OK ] %-48s %s\n" "$d" "$ip"
  else
    printf "  [FAIL] %-48s %s\n" "$d" "${ip:-$(msg noanswer)}"
    control_ok=0
  fi
done

echo
[ "$control_ok" -eq 1 ] || msg r_ctrl
total="${#DOMAINS[@]}"
if [ "$blocked" -eq "$total" ] && [ "$control_ok" -eq 1 ]; then
  msg r_ok "$blocked" "$total"; exit 0
elif [ "$blocked" -gt 0 ]; then
  msg r_part "$blocked" "$total"; exit 1
else
  msg r_none; exit 1
fi
