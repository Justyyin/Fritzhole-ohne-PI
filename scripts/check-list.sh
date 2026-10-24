#!/usr/bin/env bash
#
# check-list.sh
#
# Validates a filter list URL before it is added to the FRITZ!Box:
# reachability, file format, number of entries and list header.
#
# Prüft eine Filterlisten-URL, bevor sie in die FRITZ!Box eingetragen wird:
# Erreichbarkeit, Dateiformat, Anzahl der Einträge und Listenkopf.
#
# Usage / Aufruf:
#   ./check-list.sh [--lang de|en] <URL>
#
# SPDX-License-Identifier: MIT

set -euo pipefail

case "${LANG:-}${LC_ALL:-}" in
  *de_*|*de-*) UI_LANG="de" ;;
  *)           UI_LANG="en" ;;
esac

if [ "${1:-}" = "--lang" ]; then UI_LANG="${2:?}"; shift 2; fi
URL="${1:-}"

say() { if [ "$UI_LANG" = "de" ]; then printf "%s\n" "$1"; else printf "%s\n" "$2"; fi; }

if [ -z "$URL" ]; then
  say "Aufruf: $0 [--lang de|en] <URL der Filterliste>" "Usage: $0 [--lang de|en] <filter list URL>"
  exit 2
fi

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

say "Prüfe: $URL" "Checking: $URL"
code="$(curl -sSL --max-time 60 -o "$TMP" -w '%{http_code}' "$URL" || echo 000)"
if [ "$code" != "200" ]; then
  say "[FAIL] HTTP $code, Liste nicht erreichbar." "[FAIL] HTTP $code, list not reachable."
  exit 1
fi

bytes="$(wc -c < "$TMP" | tr -d ' ')"
entries="$(grep -cvE '^[[:space:]]*(#|!|$)' "$TMP" || true)"
size="$(numfmt --to=iec "$bytes" 2>/dev/null || echo "$bytes B")"
say "[ OK ] erreichbar, $size, $entries Einträge" "[ OK ] reachable, $size, $entries entries"

if grep -qE '^\|\|' "$TMP"; then
  say "[WARN] Adblock-Syntax erkannt (||domain^). Für die FRITZ!Box die Variante wildcard/...-onlydomains.txt verwenden." \
      "[WARN] Adblock syntax detected (||domain^). Use the wildcard/...-onlydomains.txt variant for the FRITZ!Box."
elif grep -qE '^(0\.0\.0\.0|127\.0\.0\.1)[[:space:]]' "$TMP"; then
  say "[WARN] Hosts-Format erkannt. Für die FRITZ!Box die Variante wildcard/...-onlydomains.txt verwenden." \
      "[WARN] Hosts format detected. Use the wildcard/...-onlydomains.txt variant for the FRITZ!Box."
else
  say "[ OK ] Format: eine Domain pro Zeile, geeignet für die FRITZ!Box." \
      "[ OK ] Format: one domain per line, suitable for the FRITZ!Box."
fi

case "$URL" in
  *raw.githubusercontent.com*)
    say "[INFO] Empfehlung: jsDelivr-URL statt raw.githubusercontent.com verwenden (weniger Drosselung)." \
        "[INFO] Recommendation: use the jsDelivr URL instead of raw.githubusercontent.com (less throttling)." ;;
esac

if [ "$entries" -gt 400000 ]; then
  say "[WARN] Sehr große Liste. Der Speicher der FRITZ!Box reicht dafür möglicherweise nicht aus." \
      "[WARN] Very large list. The memory of the FRITZ!Box may not be sufficient."
fi

echo
say "Listenkopf:" "List header:"
grep -E '^[[:space:]]*#' "$TMP" | head -n 14 || true
