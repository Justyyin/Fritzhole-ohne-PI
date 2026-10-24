# FRITZ!Box DNS-Filter ohne Raspberry Pi

**Deutsch** | [English](README.en.md)

[![FRITZ!OS](https://img.shields.io/badge/FRITZ!OS-8.40%20Labor%20%7C%208.50-1565c0)](#2-voraussetzungen)
[![Kosten](https://img.shields.io/badge/Kosten-0%20EUR-2e7d32)](#)
[![Filterlisten](https://img.shields.io/badge/Filterlisten-hagezi%2Fdns--blocklists-ef6c00)](https://github.com/hagezi/dns-blocklists)
[![Dokumentation](https://img.shields.io/badge/Dokumentation-CC%20BY%204.0-6b7280)](LICENSE-docs)
[![Skripte](https://img.shields.io/badge/Skripte-MIT-6b7280)](LICENSE)

Netzwerkweite Filterung von Werbung, Trackern, Phishing- und Malware-Domains mit dem in **FRITZ!OS 8.40 (Labor)** und **FRITZ!OS 8.50** integrierten **DNS-Filter**. Die Lösung benötigt keine zusätzliche Hardware wie einen Raspberry Pi, keine Container und keine kostenpflichtigen Dienste.

Als Sperrlisten werden die frei verfügbaren Listen aus dem Projekt [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) verwendet. Das Projekt führt die FRITZ!Box in seiner Formatübersicht ausdrücklich als unterstütztes System.

> [!IMPORTANT]
> Dieses Projekt ist eine unabhängige Dokumentation. Es besteht keine Verbindung zur FRITZ! GmbH (vormals AVM) oder zum Projekt hagezi/dns-blocklists. FRITZ!, FRITZ!Box und FRITZ!OS sind Marken der FRITZ! GmbH.
> Die Inhalte stellen keine Rechtsberatung dar. Änderungen an der Router-Konfiguration erfolgen auf eigene Verantwortung. Vor jeder Änderung ist eine Sicherung anzulegen.

> [!NOTE]
> Die Bildschirmfotos stammen von einer **FRITZ!Box 6690 Cable**. Rote Nummern kennzeichnen die Reihenfolge der Bedienschritte. Auf anderen Modellen und FRITZ!OS-Versionen können Menüpunkte und Beschriftungen abweichen.

Stand: 24.10.2026

---

## Inhalt

1. [Funktionsweise](#1-funktionsweise)
2. [Voraussetzungen](#2-voraussetzungen)
3. [Schritt 1: Konfiguration sichern](#3-schritt-1-konfiguration-sichern)
4. [Schritt 2: FRITZ!OS aktualisieren](#4-schritt-2-fritzos-aktualisieren)
5. [Schritt 3: Filterliste auswählen](#5-schritt-3-filterliste-auswählen)
6. [Schritt 4: DNS-Filter einrichten](#6-schritt-4-dns-filter-einrichten)
7. [Schritt 5: DNS-Konfiguration der FRITZ!Box prüfen](#7-schritt-5-dns-konfiguration-der-fritzbox-prüfen)
8. [Schritt 6: Funktion testen](#8-schritt-6-funktion-testen)
9. [Schritt 7: Endgeräte prüfen](#9-schritt-7-endgeräte-prüfen)
10. [Schritt 8: Domain-Ausnahmen pflegen](#10-schritt-8-domain-ausnahmen-pflegen)
11. [Schritt 9: Abschlusssicherung](#11-schritt-9-abschlusssicherung)
12. [Alternative für Modelle ohne DNS-Filter](#12-alternative-für-modelle-ohne-dns-filter)
13. [Fehlerbehebung](#13-fehlerbehebung)
14. [Rechtliche Hinweise](#14-rechtliche-hinweise)
15. [Grenzen und Vergleich](#15-grenzen-und-vergleich)
16. [Häufige Fragen](#16-häufige-fragen)
17. [Projektstruktur](#17-projektstruktur)
18. [Danksagung und Quellen](#18-danksagung-und-quellen)
19. [Lizenz](#19-lizenz)

### Kurzfassung

```text
1. System > Sicherung > Sichern                       Sicherung mit Kennwort anlegen
2. System > Update                                    FRITZ!OS 8.50 (oder 8.40 Labor) installieren
3. Heimnetz > Netzwerk > Netzwerkeinstellungen
   > Erweiterte Netzwerkeinstellungen > Reiter DNS-Filter
4. "DNS-Filterlisten nutzen ..." aktivieren > Übernehmen
5. Filterliste hinzufügen:
     Name: HaGeZi Multi NORMAL
     URL:  https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt
   Aktualisierung: Täglich > Übernehmen > Filterlisten aktualisieren
6. Reiter IPv4: Lokaler DNS-Server = Adresse der FRITZ!Box
7. nslookup <Domain aus der Liste>                    Erwartet: Server fritz.box, Address 0.0.0.0
```

---

## 1. Funktionsweise

### 1.1 DNS

Geräte im Internet werden über IP-Adressen angesprochen. Das Domain Name System (DNS) übersetzt Namen wie `wikipedia.org` in diese Adressen. Bevor ein Gerät eine Webseite, ein Werbebanner oder einen Tracker lädt, stellt es eine DNS-Anfrage.

```bash
nslookup wikipedia.org
```

```text
Server:   fritz.box
Address:  192.168.178.1

Name:     wikipedia.org
Address:  185.15.59.224
```

Die ersten beiden Zeilen zeigen den befragten DNS-Server. Im Auslieferungszustand ist das die FRITZ!Box, da sie ihre eigene Adresse per DHCP als DNS-Server an alle Geräte verteilt.

### 1.2 Der DNS-Filter

```text
 Endgerät                     FRITZ!Box                              Ergebnis
 ---------                    ---------                              --------
 "Welche IP hat        --->   Domain auf der Sperrliste?
  ads.example.com?"              |
                                 +-- ja   --> Antwort 0.0.0.0    --> Inhalt wird nicht geladen
                                 |
                                 +-- nein --> Upstream-DNS       --> reguläre Antwort, Seite lädt
```

Die FRITZ!Box gleicht jede eingehende DNS-Anfrage mit den hinterlegten Sperrlisten ab. Steht die Domain auf der Liste, antwortet die Box mit `0.0.0.0`. Das Gerät erhält keine gültige Zieladresse. Andernfalls wird die Anfrage an den Upstream-DNS-Server weitergeleitet und normal beantwortet.

### 1.3 Eigenschaften

| Eigenschaft | Beschreibung |
|---|---|
| Netzwerkweit | Gilt für alle Geräte, die die FRITZ!Box als DNS-Server verwenden, einschließlich Smart-TV, Spielekonsole und Apps |
| Keine Software auf Endgeräten | Die Filterung erfolgt zentral im Router |
| Gastnetz | Laut Änderungsprotokoll von FRITZ! werden DNS-Anfragen aus Heim- und Gastnetz gefiltert |
| Datensparsam | Die Box führt kein Abfrageprotokoll |
| Sicherheit | Bekannte Phishing-, Malware- und Betrugsdomains werden zusätzlich blockiert |

Technisch bedingte Grenzen sind in [Abschnitt 15](#15-grenzen-und-vergleich) beschrieben.

---

## 2. Voraussetzungen

### 2.1 Checkliste

- [ ] FRITZ!Box aus der Modellliste in 2.2
- [ ] FRITZ!OS 8.50 oder FRITZ!OS 8.40 Labor
- [ ] Computer mit Browser, idealerweise per LAN-Kabel verbunden
- [ ] Kennwort der FRITZ!Box-Oberfläche
- [ ] Etwa 20 Minuten Zeit, davon einige Minuten ohne Internetverbindung (Neustart)

### 2.2 Unterstützte Modelle

Stand Labor-Reihe 8.4x laut Fachpresse und FRITZ! Labor:

| Anschluss | Modelle |
|---|---|
| DSL | 7690, 7630, 7590 AX, 7590, 7530 AX |
| Glasfaser | 5690 Pro, 5690 XGS, 5690, 5590 Fiber |
| Kabel | 6690 Cable, 6670 Cable, 6660 Cable |
| Ohne Modem | 4690, 4630, 4050 |
| Mobilfunk | 6850 5G, 6850 5G v2, 6850 4G, 6850 LTE |

Verbindlich ist das Angebot unter **System > Update** bzw. die Seite *FRITZ! Labor* auf fritz.com. Für ältere Modelle wie 7490, 7530 (ohne AX) oder 6490 siehe [Abschnitt 12](#12-alternative-für-modelle-ohne-dns-filter).

### 2.3 Modell und Version ermitteln

1. `http://fritz.box` oder `http://192.168.178.1` im Browser öffnen und anmelden.
2. Die Seite **Übersicht** zeigt Modell und FRITZ!OS-Version.
3. Fehlende Menüpunkte werden sichtbar, wenn die Ansicht auf **Erweitert** gestellt wird.

---

## 3. Schritt 1: Konfiguration sichern

Die Sicherungsdatei enthält die vollständige Konfiguration: Internetzugangsdaten, Telefonie, WLAN-Schlüssel, Portfreigaben, VPN, Smart Home und Benutzerkonten.

**Menü:** `System > Sicherung > Reiter Sichern`

1. Kennwort für die Sicherungsdatei vergeben und bestätigen. Ohne Kennwort werden Zugangsdaten nicht gesichert.
2. **Sichern** klicken und die Aktion gegebenenfalls am Gerät bestätigen.
3. Datei mit der Endung `.export` speichern. Blockiert der Browser den Download, **Beibehalten** wählen.

Empfohlene Ablage:

```text
FRITZBox-6690_vor-Update_2026-10-24.export        Kopie 1: lokal
                                                  Kopie 2: externer Datenträger oder verschlüsselter Speicher
Kennwort                                          getrennt von der Datei, z. B. im Passwortmanager
```

> [!CAUTION]
> Sicherungsdateien enthalten Zugangsdaten. Sie dürfen nicht in ein Git-Repository gelangen. Die mitgelieferte [`.gitignore`](.gitignore) schließt `*.export` aus.

**Wiederherstellung:** `System > Sicherung > Reiter Wiederherstellen`, Datei auswählen, Kennwort eingeben, optional Teilbereiche wählen. Eine Sicherung aus einer neueren FRITZ!OS-Version lässt sich in einer älteren Version unter Umständen nicht vollständig einspielen. Deshalb wird in [Schritt 9](#11-schritt-9-abschlusssicherung) eine zweite Sicherung angelegt.

---

## 4. Schritt 2: FRITZ!OS aktualisieren

### 4.1 Reguläres Update auf 8.50 (empfohlen)

1. `System > Update > Reiter FRITZ!OS-Version` öffnen.
2. **Neues FRITZ!OS suchen** klicken.
3. Wird 8.50 oder neuer angeboten, **Update starten** wählen.
4. Nach dem Neustart unter **Übersicht** die Version prüfen.

FRITZ!OS 8.50 wird seit dem 30.09.2026 schrittweise verteilt, zuerst für die 7690 und in den folgenden Wochen für weitere Modelle. Ist 8.50 noch nicht verfügbar, kann die Laborversion verwendet werden.

### 4.2 Laborversion 8.40 installieren

Laborversionen sind Vorabversionen des Herstellers. Sie können Fehler enthalten, der Wechsel zurück zur regulären Version ist jedoch vorgesehen. Mit dem Download gelten die Nutzungsbedingungen für das FRITZ! Labor.

> [!WARNING]
> Bei Abhängigkeit von stabilem Internet oder Festnetztelefonie (Homeoffice, Hausnotruf, Notrufe) ist das reguläre Update abzuwarten.

1. Auf der Box muss die aktuelle reguläre Version installiert sein.
2. Auf fritz.com die Seite **FRITZ! Labor** öffnen und die Laborversion für das eigene Modell herunterladen.
3. Das ZIP-Archiv entpacken. Es enthält eine Datei mit der Endung `.image`.

   ```bash
   unzip FRITZ.Box_6690_Cable-Labor-*.zip -d fritz-labor
   ls fritz-labor/*.image
   ```

4. `System > Update > Reiter FRITZ!OS-Datei` öffnen.
5. Die `.image`-Datei auswählen und **Update starten**. Die Stromversorgung darf während des Updates nicht unterbrochen werden.

Nach dem Neustart zeigt die Übersicht eine Version `8.40-xxxxxx` mit dem Zusatz *Labor*.

### 4.3 Rückkehr zur regulären Version

`System > Update > Reiter FRITZ!OS-Version` bietet den Wechsel zur regulären Version an. Die übrigen Einstellungen bleiben in der Regel erhalten. Andernfalls wird die Sicherung aus Schritt 1 eingespielt.

---

## 5. Schritt 3: Filterliste auswählen

### 5.1 Quelle: hagezi/dns-blocklists

| | |
|---|---|
| Projekt | [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) |
| Lizenz | GPL-3.0 |
| Fehlalarme melden | [Issues](https://github.com/hagezi/dns-blocklists/issues) |
| Aktualisierung | mehrmals täglich, Gültigkeit laut Listenkopf 8 Stunden |
| FRITZ!Box-Format | *Wildcard Domains*, laut Projekt ab FRITZ!OS 8.40 |

### 5.2 Aufbau der URL und Dateiformat

```text
https://cdn.jsdelivr.net/gh/  hagezi/dns-blocklists  @latest/  wildcard/  multi  -onlydomains.txt
|--------------------------|  |-------------------|  |------|  |-------|  |---|  |--------------|
 CDN (jsDelivr)               GitHub-Repository      Version   Format     Stufe  Dateiendung
```

Die Listen werden in mehreren Formaten angeboten. Die FRITZ!Box verarbeitet zuverlässig das Format **Wildcard Domains**: eine Domain pro Zeile, Kommentare mit `#`. Ein Eintrag sperrt die Domain einschließlich aller Subdomains.

| Format | Pfad | Beispielinhalt | FRITZ!Box |
|---|---|---|---|
| Adblock | `adblock/multi.txt` | `\|\|ads.example.com^` | nicht geeignet |
| Hosts | `hosts/multi.txt` | `0.0.0.0 ads.example.com` | nicht geeignet |
| **Wildcard Domains** | `wildcard/multi-onlydomains.txt` | `ads.example.com` | **geeignet** |

Eine geeignete URL liegt im Verzeichnis `/wildcard/` und endet auf `-onlydomains.txt`. Die URLs verwenden das CDN jsDelivr. Es ist zuverlässiger als `raw.githubusercontent.com`, dessen Abrufe gelegentlich gedrosselt werden. Weitere Spiegelserver und ein Link-Generator sind im Projekt dokumentiert.

### 5.3 Listenstufen

Es wird genau eine Hauptliste gewählt. Höhere Stufen enthalten die niedrigeren.

| Liste | Einträge (ca.) | Inhalt | Risiko für Fehlblockierungen | Einsatz |
|---|---:|---|---|---|
| Light | 70.000 | Werbung, Tracker, Telemetrie | sehr gering | Haushalte ohne technische Betreuung |
| **Normal** | 172.000 | zusätzlich Phishing, Malware, Betrug, Cryptojacking | gering | **empfohlener Einstieg** |
| Pro | 209.000 | erweitert | mittel | Empfehlung des Projekts, nach einer Eingewöhnungsphase |
| Pro++ | 223.000 | aggressiver | erhöht | bei aktiver Pflege von Ausnahmen |
| Ultimate | 247.000 | maximal | hoch | für netzwerkweiten Einsatz nicht empfohlen |

Die Zahlen stammen aus dem Projekt (Stand 24.10.2026) und ändern sich mit jedem Build.

```text
Light:   https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/light-onlydomains.txt
Normal:  https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt
Pro:     https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro-onlydomains.txt
Pro++:   https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.plus-onlydomains.txt
```

### 5.4 Ergänzende Listen

Ergänzende Listen werden als separate Einträge neben der Hauptliste hinzugefügt.

| Liste | Zweck | Hinweis |
|---|---|---|
| TIF mini | Phishing, Malware, Betrug | Die vollständige TIF-Liste umfasst rund 2 Mio. Einträge und ist für die meisten Geräte zu groß |
| Fake | Fake-Shops, Abofallen | klein |
| Pop-Up Ads | Pop-up-Werbung | klein |
| NoSafeSearch | sperrt Suchmaschinen ohne SafeSearch | für Haushalte mit Kindern |

```text
TIF mini:      https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/tif.mini-onlydomains.txt
Fake:          https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/fake-onlydomains.txt
Pop-Up Ads:    https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/popupads-onlydomains.txt
NoSafeSearch:  https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/nosafesearch-onlydomains.txt
```

> [!WARNING]
> Der Arbeitsspeicher der FRITZ!Box ist begrenzt. Bei einer Fehlermeldung zu unzureichendem Speicher ist eine kleinere Hauptliste zu wählen oder eine ergänzende Liste zu entfernen.

### 5.5 Liste vor dem Eintragen prüfen

```bash
chmod +x scripts/check-list.sh
./scripts/check-list.sh https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt
```

```text
Prüfe: https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt
[ OK ] erreichbar, 3.3M, 172193 Einträge
[ OK ] Format: eine Domain pro Zeile, geeignet für die FRITZ!Box.

Listenkopf:
# Title: HaGeZi's Multi NORMAL - all-round protection
# Homepage: https://github.com/hagezi/dns-blocklists
# License: https://github.com/hagezi/dns-blocklists/blob/main/LICENSE
# Expires: 8 hours
# Last modified: 24 Oct 2026 08:58 UTC
# Number of entries: 172193
```

Das Skript warnt bei Adblock- oder Hosts-Format, bei sehr großen Listen und bei Verwendung von `raw.githubusercontent.com`.

---

## 6. Schritt 4: DNS-Filter einrichten

### 6.1 DNS-Filter aktivieren

**Menü:** `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen > Reiter DNS-Filter`

![DNS-Filter aktivieren](docs/img/01-dns-filter-enable.jpg)

| Nr. | Aktion |
|---|---|
| 1 | Menü **Heimnetz**, Unterpunkt **Netzwerk** öffnen. Im Reiter *Netzwerkeinstellungen* bis zum Seitenende scrollen und **Erweiterte Netzwerkeinstellungen** öffnen. |
| 2 | Reiter **DNS-Filter** wählen |
| 3 | Unter *FRITZ!Box als DNS-Filter* die Option **DNS-Filterlisten nutzen und den Zugriff auf schädliche oder unerwünschte Webseiten blockieren** aktivieren |
| 4 | **Übernehmen**. Anschließend erscheinen die Bereiche *DNS-Filterlisten* und *Domain-Ausnahmen*. |

Erscheint der Reiter *DNS-Filter* nicht, ist die Seite neu zu laden, die Ansicht auf *Erweitert* zu stellen und die FRITZ!OS-Version zu prüfen.

### 6.2 Filterlisten verwalten

Nach der Aktivierung zeigt der Reiter die Filterlisten und die Domain-Ausnahmen.

![Bereich DNS-Filterlisten](docs/img/02-dns-filter-lists.jpg)

| Nr. | Element | Aktion |
|---|---|---|
| 1 | **Aktualisierung** | Intervall für den automatischen Abruf der Listen. Empfohlen: **Täglich**. |
| 2 | **Filterliste hinzufügen** | öffnet den Dialog aus 6.3 |
| 3 | **Filterlisten aktualisieren** | lädt alle eingetragenen Listen sofort neu. Die Schaltfläche ist aktiv, sobald mindestens eine Liste eingetragen ist. |

Die Tabelle zeigt für jede Liste den Namen, den Zeitpunkt der letzten Aktualisierung und die URL. Anhand der Spalte *Letzte Aktualisierung* lässt sich prüfen, ob der Abruf funktioniert.

### 6.3 Filterliste hinzufügen

![Dialog DNS-Filterliste hinzufügen](docs/img/03-dns-filter-add-list-dialog.jpg)

| Nr. | Feld | Wert |
|---|---|---|
| 1 | Name | `HaGeZi Multi NORMAL` |
| 2 | URL der DNS-Filterliste | `https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt` |
| 3 | | **Hinzufügen**. Die Schaltfläche wird aktiv, sobald beide Felder ausgefüllt sind. |

Danach **Übernehmen** und **Filterlisten aktualisieren** klicken. Nach etwa einer Minute erscheint in der Spalte *Letzte Aktualisierung* ein Zeitstempel.

### 6.4 Aktualisierung

Das Projekt erzeugt die Listen mehrmals täglich neu. Mit der Einstellung *Aktualisierung: Täglich* ruft die FRITZ!Box die Listen einmal pro Tag ab. Ein manueller Abruf ist jederzeit über **Filterlisten aktualisieren** möglich.

Empfehlung: zunächst nur eine Liste aktivieren und einige Tage beobachten. Treten Probleme auf, ist die Ursache so eindeutig zuzuordnen.

---

## 7. Schritt 5: DNS-Konfiguration der FRITZ!Box prüfen

Der DNS-Filter wirkt nur auf Anfragen, die die FRITZ!Box erreichen. In der FRITZ!Box gibt es mehrere Stellen, die mit DNS zu tun haben. Sie werden häufig verwechselt, insbesondere nach dem Betrieb eines Pi-hole oder nach manuellen Anpassungen.

### 7.1 Überblick

```text
 Endgerät ---> [1] Lokaler DNS-Server ---> [2] DNS-Filter ---> [3] Upstream-DNS ---> Internet
               welchen DNS-Server           steht die Domain     wen fragt die Box
               erhalten die Geräte?         auf der Sperrliste?  für alle übrigen?
```

Alle Pfade beginnen mit `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen`, sofern nicht anders angegeben.

| Nr. | Einstellung | Ort | Standardwert | Anforderung für den DNS-Filter |
|---|---|---|---|---|
| 1 | Lokaler DNS-Server (IPv4) | Reiter **IPv4** | Adresse der FRITZ!Box, z. B. `192.168.178.1` | **zwingend** Adresse der FRITZ!Box |
| 1 | DNSv6-Server im Heimnetz | Reiter **IPv6** | FRITZ!Box gibt sich selbst bekannt | **zwingend** FRITZ!Box |
| 2 | DNS-Filter | Reiter **DNS-Filter** | deaktiviert | aktiviert, Liste eingetragen |
| | DNS-Rebind-Schutz | Reiter **DNS-Filter** | aktiv, keine Ausnahme | keine Änderung erforderlich |
| 3 | Upstream-DNS | `Internet > Zugangsdaten > Reiter DNS-Server` | vom Anbieter zugewiesen | frei wählbar |

### 7.2 Lokaler DNS-Server (IPv4)

Beim Verbindungsaufbau erhält jedes Gerät per DHCP eine IP-Adresse und die Adresse eines DNS-Servers. Diese DNS-Adresse wird hier festgelegt.

**Menü:** `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen > Reiter IPv4`

| Feld | Standardwert | Bedeutung |
|---|---|---|
| IPv4-Adresse | `192.168.178.1` | Adresse der FRITZ!Box im Heimnetz |
| Subnetzmaske | `255.255.255.0` | Größe des Heimnetzes |
| DHCP-Server aktivieren | aktiviert | Box verteilt Adressen und DNS-Server an die Geräte |
| Adressbereich | `192.168.178.20` bis `192.168.178.200` | Bereich für automatisch vergebene Adressen |
| **Lokaler DNS-Server** | Adresse der FRITZ!Box | DNS-Server, den die Geräte erhalten |

| Wert im Feld *Lokaler DNS-Server* | Ergebnis |
|---|---|
| Adresse der FRITZ!Box (identisch mit *IPv4-Adresse*) | korrekt, alle Anfragen erreichen den DNS-Filter |
| Adresse eines Pi-hole oder AdGuard Home | Anfragen gehen an dieses Gerät, der FRITZ!Box-Filter bleibt wirkungslos |
| Öffentlicher Server wie `8.8.8.8` oder `1.1.1.1` | Anfragen gehen direkt ins Internet, keine Filterung |

**Wiederherstellung des Standardwerts**

1. Im Feld *Lokaler DNS-Server* die IPv4-Adresse der FRITZ!Box eintragen.
2. **Übernehmen** klicken.
3. Die Geräte übernehmen die Einstellung bei der nächsten Adressvergabe. Sofort erzwingen lässt sie sich so:

```powershell
# Windows (Eingabeaufforderung oder PowerShell als Administrator)
ipconfig /release
ipconfig /renew
ipconfig /flushdns
```

```bash
# macOS (Schnittstelle en0 = WLAN bei den meisten Modellen)
sudo ipconfig set en0 DHCP
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder

# Linux mit NetworkManager
nmcli connection down "<Verbindungsname>" && nmcli connection up "<Verbindungsname>"
```

Smartphones, Smart-TVs und andere Geräte übernehmen den Wert nach dem Trennen und erneuten Verbinden mit dem WLAN.

**Umstieg von Pi-hole oder AdGuard Home**

1. Lokalen DNS-Server wie oben auf die FRITZ!Box zurücksetzen.
2. Unter `Internet > Zugangsdaten > Reiter DNS-Server` prüfen, ob der Pi-hole dort als Upstream eingetragen ist, und gegebenenfalls auf die vom Internetanbieter zugewiesenen DNS-Server zurückstellen.
3. IPv6-Einstellungen gemäß 7.3 prüfen.
4. Pi-hole erst abschalten, wenn der Test aus Schritt 6 erfolgreich ist.

### 7.3 DNSv6-Server im Heimnetz (IPv6)

IPv6-fähige Geräte erhalten ihren DNS-Server zusätzlich über Router Advertisement oder DHCPv6. Wird hier ein anderer Server bekanntgegeben, können Anfragen über IPv6 an der FRITZ!Box vorbeigehen.

**Menü:** `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen > Reiter IPv6`

| Feld | Sollwert | Bedeutung |
|---|---|---|
| Unique Local Addresses (ULA) | Standard oder *ULA immer zuweisen* | stabile lokale IPv6-Adresse der Box, unter der sie als DNS-Server erreichbar ist |
| Router Advertisement im LAN aktiv | aktiviert | Box kündigt sich als IPv6-Router an |
| DNSv6-Server auch über Router Advertisement bekanntgeben (RFC 5006) | aktiviert | Geräte ohne DHCPv6, z. B. Android, erhalten so den DNS-Server |
| Lokaler DNSv6-Server | IPv6-Adresse der FRITZ!Box (Standard) | DNS-Server, der den Geräten mitgeteilt wird |
| DHCPv6-Server im Heimnetz | aktiviert, mindestens DNS-Server zuweisen | Geräte mit DHCPv6, z. B. Windows, erhalten den DNS-Server |

Die exakte Beschriftung und die verfügbaren Optionen hängen von Modell, Anschlussart und FRITZ!OS-Version ab. Maßgeblich ist, dass als DNSv6-Server ausschließlich die FRITZ!Box bekanntgegeben wird.

**Prüfung auf dem Gerät**

```powershell
# Windows
Get-DnsClientServerAddress | Where-Object ServerAddresses |
  Format-Table InterfaceAlias, AddressFamily, ServerAddresses
```

```bash
# macOS
scutil --dns | grep nameserver | sort -u

# Linux (systemd-resolved)
resolvectl status | grep -A3 "DNS Servers"
```

Erwartet werden ausschließlich die IPv4-Adresse der FRITZ!Box und deren IPv6-Adressen (häufig beginnend mit `fd00:` oder `fe80:`).

### 7.4 Upstream-DNS

Domains, die nicht auf der Sperrliste stehen, löst die FRITZ!Box über den Upstream-DNS auf. Im Standard ist das der Server des Internetanbieters. Die Anfragen werden dabei unverschlüsselt übertragen.

**Menü:** `Internet > Zugangsdaten > Reiter DNS-Server`

**Variante A: Standard**

Die vom Internetanbieter zugewiesenen DNSv4- und DNSv6-Server verwenden. Keine weiteren Einstellungen.

**Variante B: Verschlüsselt mit DNS over TLS**

| Feld | Beispielwert (Mullvad DNS, ungefiltert) | Bedeutung |
|---|---|---|
| Andere DNSv4-Server verwenden | bevorzugt und alternativ `194.242.2.2` | IPv4-Adresse des Resolvers |
| Andere DNSv6-Server verwenden | `2a07:e340::2` | IPv6-Adresse des Resolvers. Ohne Eintrag werden IPv6-Anfragen weiterhin an den Anbieter gesendet. |
| Verschlüsselte Namensauflösung im Internet (DNS over TLS) | aktiviert | Verschlüsselung der Anfragen über TCP-Port 853 |
| Zertifikatsprüfung erzwingen | aktiviert | Verbindung nur bei gültigem Zertifikat |
| Fallback auf unverschlüsselte Namensauflösung | deaktiviert | Bei Ausfall des Resolvers keine unverschlüsselte Ausweichverbindung. Höhere Vertraulichkeit, geringere Ausfallsicherheit. |
| Auflösungsnamen der DNS-Server | `dns.mullvad.net` | Hostname für die Zertifikatsprüfung |

Abschließend **Übernehmen**.

> [!NOTE]
> Bei Mullvad funktionieren die genannten Adressen ausschließlich verschlüsselt (DoT oder DoH), nicht über klassisches DNS auf Port 53. DNS over TLS ist daher zwingend zu aktivieren.

Bei aktivem lokalen DNS-Filter wird ein **ungefilterter** Upstream empfohlen. Filtern zwei Instanzen, ist bei Fehlblockierungen die Ursache schwer zu bestimmen.

### 7.5 DNS-Rebind-Schutz

Der DNS-Rebind-Schutz unterdrückt DNS-Antworten, die auf IP-Adressen im eigenen Heimnetz verweisen. Er schützt vor Angriffen, bei denen eine Webseite über manipulierte DNS-Antworten auf Geräte im Heimnetz zugreift. Er befindet sich im selben Reiter wie der DNS-Filter.

**Menü:** `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen > Reiter DNS-Filter > DNS-Rebind-Schutz`

![DNS-Rebind-Schutz](docs/img/05-dns-rebind-protection.jpg)

| Nr. | Element | Bedeutung |
|---|---|---|
| 1 | Tabelle *Domain* | eingerichtete Ausnahmen. Standard: *Keine Ausnahme eingerichtet* |
| 2 | **Ausnahme hinzufügen** | neue Ausnahme eintragen. Erforderlich ist der vollständige Hostname (Domainname mit Subdomain), z. B. `nas.example.org`. |

Für den DNS-Filter ist hier **keine Änderung** erforderlich. Ausnahmen sind nur nötig, wenn eigene öffentliche Domains auf Geräte im Heimnetz zeigen sollen, etwa ein NAS mit eigener Domain oder ein DynDNS-Name für den lokalen Zugriff.

### 7.6 Checkliste

- [ ] Reiter IPv4: Lokaler DNS-Server ist die Adresse der FRITZ!Box
- [ ] Reiter IPv6: Als DNSv6-Server wird ausschließlich die FRITZ!Box bekanntgegeben
- [ ] Reiter DNS-Filter: Option aktiviert, Liste aus `/wildcard/...-onlydomains.txt` eingetragen, *Letzte Aktualisierung* zeigt einen Zeitstempel
- [ ] Upstream-DNS ist der Anbieterstandard oder ein ungefilterter DoT-Resolver mit IPv4- und IPv6-Adresse
- [ ] DNS-Rebind-Schutz unverändert, sofern keine eigenen Domains im Heimnetz genutzt werden
- [ ] Endgeräte verwenden kein eigenes verschlüsseltes DNS ([Schritt 7](#9-schritt-7-endgeräte-prüfen))
- [ ] Test erfolgreich ([Schritt 6](#8-schritt-6-funktion-testen))

---

## 8. Schritt 6: Funktion testen

Die FRITZ!Box zeigt keine Statistik an. Die Funktion wird daher über eine DNS-Abfrage geprüft.

### 8.1 Manueller Test

1. Die Listen-URL im Browser öffnen und die erste Domain nach den Kommentarzeilen notieren. Eine feste Testdomain wird bewusst nicht vorgegeben, da sich die Liste laufend ändert.
2. Abfrage ausführen. Unter Windows in der Eingabeaufforderung, unter macOS und Linux im Terminal:

```bash
nslookup <testdomain>
nslookup wikipedia.org
```

Erwartete Ausgabe:

```text
Server:   fritz.box                   <- das Gerät fragt die FRITZ!Box
Address:  192.168.178.1

Name:     <testdomain>
Address:  0.0.0.0                     <- Domain wird blockiert

Server:   fritz.box
Address:  192.168.178.1

Name:     wikipedia.org
Address:  185.15.59.224               <- Gegenprobe: reguläre Domain wird aufgelöst
```

| Ausgabe | Bewertung |
|---|---|
| `Server: fritz.box` bzw. `192.168.178.1` | korrekt, das Gerät fragt die FRITZ!Box |
| andere Serveradresse, z. B. `8.8.8.8` | das Gerät umgeht die FRITZ!Box, siehe [Schritt 7](#9-schritt-7-endgeräte-prüfen) |
| `Address: 0.0.0.0`, `::` oder keine Adresse | Domain wird blockiert |
| reguläre IP-Adresse für die Testdomain | Liste noch nicht aktiv: *Übernehmen*, *Filterlisten aktualisieren* und *Letzte Aktualisierung* prüfen |

Die FRITZ!Box kann unabhängig von den Geräteeinstellungen direkt abgefragt werden:

```bash
nslookup <testdomain> 192.168.178.1
```

Liefert diese Abfrage `0.0.0.0`, die Abfrage ohne Serverangabe jedoch nicht, arbeitet der Filter korrekt und das Gerät nutzt einen anderen DNS-Server.

### 8.2 Automatisierter Test

Die Skripte laden die Liste, prüfen die ersten Einträge gegen die FRITZ!Box und führen eine Gegenprobe durch.

```bash
# Linux / macOS
git clone https://github.com/<benutzer>/fritzhole-ohne-pi.git
cd fritzhole-ohne-pi
chmod +x scripts/test-dnsfilter.sh
./scripts/test-dnsfilter.sh
./scripts/test-dnsfilter.sh -s 192.168.178.1 -n 10 \
  -l https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro-onlydomains.txt
```

```powershell
# Windows PowerShell
powershell -ExecutionPolicy Bypass -File .\scripts\test-dnsfilter.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\test-dnsfilter.ps1 -Server 192.168.178.1 -Count 10
```

```text
DNS-Server : 192.168.178.1
Filterliste: https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt

Erwartet: blockiert
  [ OK ] ad.example-one.com                               0.0.0.0
  [ OK ] track.example-two.net                            0.0.0.0
  ...
Erwartet: erreichbar (Gegenprobe)
  [ OK ] wikipedia.org                                    185.15.59.224
  [ OK ] fritz.com                                        ...

Ergebnis: DNS-Filter aktiv (5/5 blockiert).
```

| Parameter (sh / ps1) | Standard | Bedeutung |
|---|---|---|
| `-s` / `-Server` | `192.168.178.1` | abzufragender DNS-Server |
| `-l` / `-ListUrl` | Multi NORMAL | Filterliste, aus der Testdomains gelesen werden |
| `-n` / `-Count` | `5` | Anzahl der Testdomains |
| `--lang` / `-Lang` | Systemsprache | Ausgabesprache `de` oder `en` |

| Exit-Code | Bedeutung |
|---|---|
| `0` | Filter aktiv |
| `1` | teilweise oder nicht aktiv |
| `2` | Aufruf- oder Umgebungsfehler |

Abhängigkeiten unter Linux: `curl` und `nslookup` (Paket `dnsutils` bzw. `bind-utils`).

---

## 9. Schritt 7: Endgeräte prüfen

Endgeräte können eigene DNS-Server verwenden und damit die FRITZ!Box umgehen. Folgende Einstellungen sind zu prüfen.

### 9.1 Browser: Sicheres DNS (DNS over HTTPS)

| Browser | Einstellung | Sollwert |
|---|---|---|
| Firefox | `about:preferences#privacy`, Abschnitt *DNS über HTTPS* | *Standardschutz* oder *Aus* |
| Chrome | `chrome://settings/security`, *Sicheres DNS verwenden* | *Mit Ihrem aktuellen Dienstanbieter* oder aus |
| Edge | `edge://settings/privacy`, *Sicheres DNS* | *Aktuellen Dienstanbieter verwenden* |
| Brave | `brave://settings/security`, *Sicheres DNS* | *Mit Ihrem aktuellen Dienstanbieter* |

### 9.2 Smartphones und Tablets

| System | Einstellung | Sollwert |
|---|---|---|
| Android | `Einstellungen > Netzwerk und Internet > Privates DNS` | *Aus* oder *Automatisch* |
| iOS / iPadOS | `Einstellungen > WLAN > (i) beim Heimnetz > iCloud Privat-Relay` | für das Heim-WLAN deaktiviert |
| iOS / iPadOS | `Einstellungen > Allgemein > VPN und Geräteverwaltung` | kein DNS-Profil eines Drittanbieters |

### 9.3 Fest konfigurierte DNS-Server

Die in [7.3](#73-dnsv6-server-im-heimnetz-ipv6) genannten Befehle zeigen die verwendeten DNS-Server. Ist eine fremde Adresse eingetragen, wird die DNS-Konfiguration des Geräts auf *automatisch (DHCP)* umgestellt.

### 9.4 VPN und fest eingebaute DNS-Server

- Ein aktives VPN leitet DNS-Anfragen in der Regel durch den Tunnel zum VPN-Anbieter. Der Filter greift dann erwartungsgemäß nicht.
- Einige Smart-TVs und IoT-Geräte verwenden fest einprogrammierte DNS-Server. Abhilfe schafft, sofern vorhanden, die DNS-Einstellung im Gerätemenü. Eine Sperre öffentlicher DNS-Server über Zugangsprofile ist möglich, aber aufwendig und kann Gerätefunktionen beeinträchtigen.

---

## 10. Schritt 8: Domain-Ausnahmen pflegen

Sperrlisten enthalten gelegentlich Domains, die für einzelne Dienste erforderlich sind. In diesem Fall wird nur die betroffene Domain freigegeben, nicht der gesamte Filter deaktiviert. Umgekehrt lassen sich einzelne Domains zusätzlich sperren. Domain-Ausnahmen haben Vorrang vor allen Filterlisten.

### 10.1 Typische Fälle

| Symptom | Häufige Ursache |
|---|---|
| Link in Newsletter oder Versandbenachrichtigung öffnet nicht | Klick-Tracking-Domain des Versenders |
| Gesponserte Suchergebnisse oder Preisvergleiche leiten nicht weiter | Affiliate- oder Weiterleitungsdomain |
| Streamingdienst auf dem Smart-TV startet nicht | Telemetriedomain des Herstellers |
| Anmeldung in einer App schlägt fehl | Analyse- oder Attributionsdienst der App |

### 10.2 Ursache ermitteln

1. Betroffene Seite in einem Desktop-Browser öffnen.
2. Entwicklerwerkzeuge mit **F12** öffnen, Reiter **Netzwerk**, Seite neu laden.
3. Fehlgeschlagene Anfragen (`ERR_NAME_NOT_RESOLVED`) notieren.
4. Kandidaten mit `nslookup <domain>` prüfen. `0.0.0.0` bestätigt die Blockierung.

Alternativ wird der Filter kurzzeitig deaktiviert. Funktioniert der Dienst dann, liegt die Ursache im Filter. Anschließend den Filter wieder aktivieren.

### 10.3 Ausnahme eintragen

**Menü:** `Heimnetz > Netzwerk > Netzwerkeinstellungen > Erweiterte Netzwerkeinstellungen > Reiter DNS-Filter > Domain-Ausnahmen`

![Domain-Ausnahmen](docs/img/04-domain-exceptions.jpg)

| Nr. | Element | Bedeutung |
|---|---|---|
| 1 | Tabelle mit den Gruppen **Erlaubt** und **Gesperrt** | *Erlaubt*: Domain wird trotz Filterliste aufgelöst. *Gesperrt*: Domain wird zusätzlich blockiert. Die Spalte *Notiz* dokumentiert den Grund. |
| 2 | **Eigene Domain hinzufügen** | neue Ausnahme anlegen: Domainnamen ohne `https://` und ohne Pfad eintragen, z. B. `click.example.com`, als erlaubt oder gesperrt einordnen und eine Notiz vergeben |

Abschließend **Übernehmen**. Ausnahmen werden zusätzlich in [`lists/allowlist-template.txt`](lists/allowlist-template.txt) mit Datum und Grund dokumentiert, damit sie nach einem Reset reproduzierbar sind.

### 10.4 Fehlalarm melden

Ist eine seriöse Domain fälschlich gelistet, kann sie im Projekt gemeldet werden: [hagezi/dns-blocklists Issues](https://github.com/hagezi/dns-blocklists/issues). Vorher ist zu prüfen, ob bereits eine Meldung existiert.

---

## 11. Schritt 9: Abschlusssicherung

Nach erfolgreicher Einrichtung und Prüfung wird eine zweite Sicherung angelegt (Vorgehen wie in [Schritt 1](#3-schritt-1-konfiguration-sichern)).

```text
Sicherung 1  ---> Firmware-Update ---> DNS-Filter einrichten ---> Sicherung 2
vor Update                             und testen                 nach Einrichtung
```

| Datei | Zweck |
|---|---|
| `..._vor-Update_<Datum>.export` | Rückkehr zur vorherigen Firmware |
| `..._mit-DNS-Filter_<Datum>.export` | Wiederherstellung der fertigen Konfiguration nach einem Reset |

---

## 12. Alternative für Modelle ohne DNS-Filter

Für Modelle ohne DNS-Filter oder ohne gewünschte Laborversion kann ein öffentlicher DNS-Dienst mit integrierter Filterung als Upstream eingetragen werden. Die Einrichtung entspricht [Variante B in 7.4](#74-upstream-dns), jedoch mit gefilterten Adressen.

> [!WARNING]
> Bei dieser Variante filtert der Anbieter und nicht die FRITZ!Box. Sämtliche DNS-Anfragen des Haushalts werden an den Anbieter übermittelt. Eigene Listen und Ausnahmen sind nicht möglich. Die Datenschutzerklärung des Anbieters ist zu prüfen.

**Mullvad DNS** (kein Konto erforderlich, nur verschlüsselt nutzbar)

| Profil | Filter | DoT-Hostname | IPv4 | IPv6 |
|---|---|---|---|---|
| adblock | Werbung, Tracker | `adblock.dns.mullvad.net` | `194.242.2.3` | `2a07:e340::3` |
| base | zusätzlich Malware | `base.dns.mullvad.net` | `194.242.2.4` | `2a07:e340::4` |
| extended | zusätzlich soziale Netzwerke | `extended.dns.mullvad.net` | `194.242.2.5` | `2a07:e340::5` |
| family | zusätzlich Erwachseneninhalte, Glücksspiel | `family.dns.mullvad.net` | `194.242.2.6` | `2a07:e340::6` |
| all | alle Kategorien | `all.dns.mullvad.net` | `194.242.2.9` | `2a07:e340::9` |

**AdGuard DNS** (öffentlich)

| Profil | DoT-Hostname | IPv4 | IPv6 |
|---|---|---|---|
| Standard | `dns.adguard-dns.com` | `94.140.14.14`, `94.140.15.15` | `2a10:50c0::ad1:ff`, `2a10:50c0::ad2:ff` |
| Family | `family.adguard-dns.com` | `94.140.14.15`, `94.140.15.16` | `2a10:50c0::bad1:ff`, `2a10:50c0::bad2:ff` |

IPv6-Adressen sind immer mit einzutragen, da IPv6-Anfragen sonst ungefiltert an den Internetanbieter gehen. Adressen von Drittanbietern können sich ändern und sind vor der Einrichtung auf der Anbieterseite zu prüfen.

---

## 13. Fehlerbehebung

| Problem | Ursache | Lösung |
|---|---|---|
| Reiter *DNS-Filter* fehlt | FRITZ!OS zu alt oder Ansicht *Standard* | Version prüfen, Ansicht *Erweitert*, Seite neu laden |
| Bereich *DNS-Filterlisten* fehlt | Option *DNS-Filterlisten nutzen* nicht aktiv oder nicht übernommen | Option aktivieren, *Übernehmen* |
| Liste eingetragen, keine Wirkung | *Übernehmen* nicht ausgeführt | *Übernehmen*, dann *Filterlisten aktualisieren* |
| Liste eingetragen, keine Wirkung | falsches Format, z. B. `adblock/multi.txt` | URL aus `/wildcard/...-onlydomains.txt` verwenden |
| *Letzte Aktualisierung* bleibt leer | Liste nicht erreichbar oder durch GitHub gedrosselt | jsDelivr-URL oder Spiegelserver verwenden, URL mit `check-list.sh` prüfen |
| Meldung zu unzureichendem Speicher | Liste zu groß | kleinere Hauptliste, ergänzende Listen entfernen |
| `nslookup` zeigt fremden Server | lokaler DNS-Server falsch oder Gerät fest konfiguriert | [7.2](#72-lokaler-dns-server-ipv4), [Schritt 7](#9-schritt-7-endgeräte-prüfen) |
| Filter wirkt nur teilweise | IPv6-DNS zeigt nicht auf die Box | [7.3](#73-dnsv6-server-im-heimnetz-ipv6) |
| Einzelnes Gerät zeigt weiterhin Werbung | Sicheres DNS, Privates DNS, VPN | [Schritt 7](#9-schritt-7-endgeräte-prüfen) |
| Dienst oder Link funktioniert nicht | Fehlblockierung | [Schritt 8](#10-schritt-8-domain-ausnahmen-pflegen) |
| Kurze Hostnamen wie `nas` lösen nicht auf | seit 8.40 wird das Suffix `fritz.box` nicht mehr per DHCP verteilt | vollständigen Namen `nas.fritz.box` verwenden |
| Instabilität mit Laborversion | Vorabversion | neueren Labor-Build installieren oder [zurückwechseln](#43-rückkehr-zur-regulären-version) |

Sofortige Deaktivierung: im Reiter *DNS-Filter* die Option *DNS-Filterlisten nutzen* deaktivieren und **Übernehmen**. Die eingetragenen Listen bleiben erhalten.

---

## 14. Rechtliche Hinweise

Kurzfassung. Ausführlich in [docs/de/rechtliches.md](docs/de/rechtliches.md). Die Ausführungen beziehen sich auf Deutschland, Stand Oktober 2026, und stellen keine Rechtsberatung dar.

| Thema | Einordnung |
|---|---|
| Zulässigkeit von Werbeblockern | Der BGH hat 2018 entschieden, dass Werbeblocker keine unlautere Behinderung darstellen (Urteil vom 19.04.2018, I ZR 154/16). Ein DNS-Filter verändert zudem keinen Webseiten-Code. |
| Nutzungsbedingungen von Diensten | Einzelne Dienste untersagen Werbeblocker. Ein Verstoß ist in der Regel kein Gesetzesverstoß, kann aber zum Ausschluss vom Dienst führen. |
| Datenschutz | Private Nutzung fällt unter die Haushaltsausnahme (Art. 2 Abs. 2 lit. c DSGVO). Der FRITZ!Box-Filter protokolliert keine Anfragen. |
| Gäste und Mitbewohner | Der Filter wirkt auch im Gastnetz. Eine transparente Information der Nutzer wird empfohlen. |
| Gewerbliche Nutzung | Für Ferienwohnungen, Gastronomie oder Unternehmen gelten weitergehende Pflichten. Nicht Gegenstand dieser Dokumentation. |
| FRITZ! Labor | Vorabsoftware des Herstellers, Nutzungsbedingungen beachten |
| Gerät des Anbieters | Bei Miet- oder Leihgeräten vertragliche Regelungen prüfen |
| Filterlisten | [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) steht unter GPL-3.0. Dieses Repository verlinkt die Listen und verbreitet sie nicht. |
| Bildschirmfotos | Die Oberfläche von FRITZ!OS ist Eigentum der FRITZ! GmbH. Die Bildschirmfotos sind nicht Teil der CC-BY-Lizenz dieses Repositorys. |

---

## 15. Grenzen und Vergleich

### 15.1 Technische Grenzen

| Grenze | Ursache |
|---|---|
| Werbung auf YouTube und ähnlichen Plattformen bleibt sichtbar | Werbung und Inhalt werden über dieselben Domains ausgeliefert |
| Keine Statistik und kein Abfrageprotokoll | in FRITZ!OS nicht vorgesehen |
| Kein Schutz im Mobilfunknetz | Gerät befindet sich nicht im Heimnetz |
| Umgehung durch DoH, Privates DNS, VPN, feste DNS-Server | Anfrage erreicht die FRITZ!Box nicht |
| Begrenzte Listengröße | Arbeitsspeicher des Routers |
| Keine Ausnahme für das Gastnetz | in FRITZ!OS nicht vorgesehen (Stand Recherche) |

### 15.2 Vergleich

| Kriterium | FRITZ!Box DNS-Filter | Pi-hole / AdGuard Home | Öffentlicher Filter-DNS |
|---|---|---|---|
| Zusätzliche Hardware | nein | ja | nein |
| Kosten | keine | Hardware und Strom | keine |
| Einrichtungsaufwand | gering | mittel | sehr gering |
| Eigene Listen und Ausnahmen | ja | ja | nein |
| Statistik und Protokoll | nein | ja | nein |
| Regeln pro Gerät | eingeschränkt | ja | nein |
| Gastnetz | automatisch | aufwendig | ja |
| Anfragen bleiben im Haus | ja | ja | nein |

Für die meisten Haushalte ist der integrierte DNS-Filter ausreichend. Pi-hole oder AdGuard Home bieten Mehrwert bei Bedarf an Statistiken oder gerätespezifischen Regeln. Beide Ansätze sollten nicht parallel betrieben werden.

---

## 16. Häufige Fragen

**Entstehen Kosten?**
Nein. Firmware, Laborversion und Filterlisten sind kostenfrei. Zusätzliche Hardware ist nicht erforderlich.

**Wird die Verbindung langsamer?**
Nein. Da Werbung und Tracker nicht geladen werden, bauen sich viele Seiten schneller auf.

**Wirkt der Filter unterwegs?**
Nicht im Mobilfunknetz. Über eine WireGuard-VPN-Verbindung zur FRITZ!Box gilt der Filter auch unterwegs, da die Anfragen dann über das Heimnetz laufen.

**Ersetzt der Filter einen Virenschutz?**
Nein. Er ergänzt ihn um die Blockierung bekannter Schaddomains.

**Wie wird die Einrichtung vollständig rückgängig gemacht?**
Option *DNS-Filterlisten nutzen* deaktivieren und übernehmen. Optional zur regulären Firmware zurückkehren oder die Sicherung aus Schritt 1 einspielen.

---

## 17. Projektstruktur

```text
.
├── README.md                          Anleitung (Deutsch)
├── README.en.md                       Guide (English)
├── docs/
│   ├── de/rechtliches.md              Rechtliche Hinweise (Deutsch)
│   ├── en/legal.md                    Legal notes (English)
│   └── img/
│       ├── 01-dns-filter-enable.jpg   Bildschirmfotos mit Schrittmarkierungen
│       ├── 02-dns-filter-lists.jpg
│       ├── 03-dns-filter-add-list-dialog.jpg
│       ├── 04-domain-exceptions.jpg
│       ├── 05-dns-rebind-protection.jpg
│       └── original/                  unbearbeitete Bildschirmfotos
├── scripts/
│   ├── test-dnsfilter.sh              Funktionstest (Linux, macOS)
│   ├── test-dnsfilter.ps1             Funktionstest (Windows)
│   └── check-list.sh                  Prüfung einer Listen-URL
├── lists/
│   └── allowlist-template.txt         Vorlage zur Dokumentation von Ausnahmen
├── .github/ISSUE_TEMPLATE/            Vorlagen für Fehlerberichte und Modellmeldungen
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE                            MIT (Skripte)
└── LICENSE-docs                       CC BY 4.0 (Dokumentation)
```

---

## 18. Danksagung und Quellen

### Danksagung

- **[hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists)**: Die in dieser Anleitung empfohlenen Filterlisten stammen aus diesem Projekt. Lizenz GPL-3.0. Dank an den Maintainer für die fortlaufende Pflege.
- **FRITZ! GmbH**: für den in FRITZ!OS integrierten DNS-Filter.
- **Mullvad** und **AdGuard**: für frei nutzbare öffentliche DNS-Dienste.

### Quellen

| Thema | Quelle |
|---|---|
| Filterlisten, Formatübersicht | https://github.com/hagezi/dns-blocklists |
| Beschreibung DNS-Filter, Menüpfad | https://fritz.com/en/pages/fritz-labor-8-40-zusatzinformationen |
| Veröffentlichung FRITZ!OS 8.50 | https://www.pcwelt.de/article/3246387/fritz-os-8-50-ist-da-stoppt-jetzt-betrugs-webseiten-und-werbung.html |
| Unterstützte Modelle | https://t3n.de/news/werbung-smart-tv-menue-fritzbox-blockieren-1763248/ |
| Praxisbericht und Grenzen | https://paules-pc-forum.de/article/95-fritz-box-als-werbeblocker-dns-filter-in-fritz-os-8-50-einrichten-fritzhole/ |
| Praxisbericht und Test | https://sakis.tech/fritz-hole-einrichten/ |
| Mullvad DNS | https://mullvad.net/de/help/dns-over-https-and-dns-over-tls |
| AdGuard DNS | https://adguard-dns.io/de/public-dns.html |

---

## 19. Lizenz

| Bestandteil | Lizenz |
|---|---|
| Dokumentation (`README*.md`, `docs/*.md`, `CONTRIBUTING.md`, `CHANGELOG.md`) | [CC BY 4.0](LICENSE-docs) |
| Skripte (`scripts/`) | [MIT](LICENSE) |
| Bildschirmfotos (`docs/img/`) | nicht von CC BY erfasst, Oberfläche (c) FRITZ! GmbH |
| Filterlisten | nicht Bestandteil dieses Repositorys, siehe [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) (GPL-3.0) |

Beiträge sind willkommen, siehe [CONTRIBUTING.md](CONTRIBUTING.md).
