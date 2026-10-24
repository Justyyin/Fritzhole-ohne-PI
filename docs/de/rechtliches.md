# Rechtliche Hinweise

[English](../en/legal.md)

Diese Hinweise fassen allgemeine Informationen zur Rechtslage in Deutschland zusammen (Stand Oktober 2026). Sie stellen keine Rechtsberatung dar. Für konkrete Fragen ist eine Rechtsanwältin, ein Rechtsanwalt oder eine Verbraucherzentrale zu konsultieren.

## 1. Zulässigkeit von Werbeblockern

- Der Bundesgerichtshof hat mit Urteil vom 19.04.2018 (I ZR 154/16, "Werbeblocker II") entschieden, dass das Angebot eines Werbeblockers weder eine gezielte Behinderung noch eine unzulässige aggressive Praktik nach dem UWG darstellt. Die Entscheidung, Werbung nicht anzuzeigen, trifft der Nutzer.
- Ein späteres urheberrechtliches Verfahren zu Browser-Erweiterungen wurde vom BGH 2025 zur erneuten Verhandlung zurückverwiesen und war zum Recherchestand nicht abschließend entschieden. Es betrifft Anbieter von Browser-Erweiterungen, nicht private Anwender.
- Ein DNS-Filter verändert keinen Programmcode einer Webseite. Er beantwortet lediglich Namensanfragen im eigenen Netz nicht. Technisch entspricht das einer Hosts-Datei oder den seit Jahren in Routern vorhandenen Jugendschutzfiltern.
- Nutzungsbedingungen einzelner Dienste können den Einsatz von Werbeblockern untersagen. Ein Verstoß ist in der Regel kein Gesetzesverstoß, kann aber zur Sperrung des Zugangs oder zur Einschränkung des Angebots führen.

## 2. Datenschutz

| Situation | Einordnung |
|---|---|
| Filterung im eigenen Haushalt | Haushaltsausnahme nach Art. 2 Abs. 2 lit. c DSGVO |
| FRITZ!Box-DNS-Filter | führt nach vorliegenden Informationen kein Abfrageprotokoll, es entstehen keine Surfprotokolle auf dem Router |
| Öffentlicher Filter-DNS als Upstream | sämtliche DNS-Anfragen werden an den Anbieter übermittelt. Datenschutzerklärung prüfen, Anbieter mit Sitz im EWR bevorzugen. |
| Abruf der Filterlisten | beim Abruf wird die öffentliche IP-Adresse des Anschlusses an den CDN-Betreiber übertragen, wie bei jedem Webseitenaufruf |

Lösungen wie Pi-hole oder AdGuard Home protokollieren standardmäßig jede Anfrage pro Gerät. Bei gemeinsamer Nutzung mit anderen Erwachsenen sollte das offengelegt werden.

## 3. Gäste, Mitbewohner und Familie

Der DNS-Filter wirkt nach Angaben des Herstellers auch im Gastnetz. Eine Ausnahme für das Gastnetz ist nach aktuellem Stand nicht vorgesehen.

Empfehlungen:

- Mitbewohner und volljährige Haushaltsmitglieder über den aktiven Filter informieren.
- Auf der Gast-WLAN-Information einen Hinweis ergänzen, etwa: "Dieses WLAN filtert bekannte Werbe-, Tracking- und Schadsoftware-Domains."
- Bei Kindern ergänzt der DNS-Filter die Kindersicherung über Zugangsprofile, ersetzt aber keine Begleitung.

Für gewerbliche Angebote (Ferienwohnung, Gastronomie, Büro, Arbeitgeber) gelten weitergehende Pflichten, unter anderem aus dem TDDDG, dem Arbeitsrecht und gegebenenfalls der Mitbestimmung. Diese Fälle sind nicht Gegenstand der Dokumentation.

## 4. FRITZ! Labor

- Mit Download und Nutzung einer Laborversion gelten die Nutzungsbedingungen für das FRITZ! Labor.
- Laborversionen sind Testsoftware. Fehler sind möglich, die Nutzung erfolgt auf eigenes Risiko.
- Die Laborversion stammt vom Hersteller und ist keine Fremdfirmware. Der Wechsel zur regulären Version ist vorgesehen.
- Bei Miet- oder Leihgeräten des Internetanbieters sind die vertraglichen Regelungen zu prüfen. Einige Anbieter verwalten die Firmware selbst oder untersagen Änderungen.

## 5. Bildschirmfotos

Die Bildschirmfotos in `docs/img/` zeigen die Benutzeroberfläche von FRITZ!OS. Die Rechte an der Oberfläche liegen bei der FRITZ! GmbH. Die Bildschirmfotos sind nicht von der CC-BY-Lizenz dieses Repositorys erfasst und werden ausschließlich zur Dokumentation verwendet. Vor der Veröffentlichung eigener Bildschirmfotos sind personenbezogene und gerätespezifische Daten zu entfernen (Gerätenamen, IP- und MAC-Adressen, WLAN-Namen, Telefonnummern, MyFRITZ!-Adressen).

## 6. Filterlisten

- Dieses Repository verlinkt Filterlisten. Es kopiert oder verbreitet sie nicht.
- Die Listen von [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) stehen unter der GPL-3.0. Wer die Listen verändert oder weiterverbreitet, hat die Bedingungen der GPL-3.0 einzuhalten.
- Andere Listen unterliegen eigenen Lizenzen.

## 7. Marken

FRITZ!, FRITZ!Box, FRITZ!OS und MyFRITZ! sind Marken der FRITZ! GmbH. Pi-hole, AdGuard und Mullvad sind Marken oder Namen ihrer jeweiligen Inhaber. Die Nennung dient ausschließlich der Beschreibung. Es besteht keine Verbindung zu den genannten Unternehmen und Projekten.

## 8. Haftung

Die Inhalte werden ohne Gewähr bereitgestellt. Für Datenverlust, Ausfälle, nicht erreichbare Dienste oder entgangene Anrufe, einschließlich Notrufen, wird keine Haftung übernommen. Vor jeder Änderung ist eine Sicherung anzulegen.

## 9. Hinweise zur Veröffentlichung eines Forks

- Keine Sicherungsdateien (`*.export`), Kennwörter, Seriennummern oder unbearbeiteten Bildschirmfotos einchecken. Die mitgelieferte `.gitignore` schließt typische Dateien aus.
- Bei einer geschäftsmäßigen Webseite mit Sitz in Deutschland ist die Impressumspflicht nach § 5 DDG zu prüfen. Ein rein privates Repository fällt in der Regel nicht darunter.
