<#
.SYNOPSIS
    Checks whether the DNS filter of a FRITZ!Box is active.
    Prüft, ob der DNS-Filter einer FRITZ!Box aktiv ist.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\test-dnsfilter.ps1
    powershell -ExecutionPolicy Bypass -File .\test-dnsfilter.ps1 -Server 192.168.178.1 -Count 10 -Lang en

.NOTES
    Exit codes: 0 = active, 1 = partially or not active, 2 = error
    SPDX-License-Identifier: MIT
#>
param(
    [string]$Server  = "192.168.178.1",
    [string]$ListUrl = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/multi-onlydomains.txt",
    [int]$Count      = 5,
    [ValidateSet("de", "en", "")]
    [string]$Lang    = ""
)

if (-not $Lang) {
    $Lang = if ((Get-Culture).TwoLetterISOLanguageName -eq "de") { "de" } else { "en" }
}

$M = @{
    de = @{
        server = "DNS-Server : {0}"; list = "Filterliste: {0}"
        nolist = "Aus der Filterliste konnten keine Testdomains gelesen werden."
        loadfail = "Filterliste konnte nicht geladen werden: {0}"
        hblock = "Erwartet: blockiert"; hallow = "Erwartet: erreichbar (Gegenprobe)"; noanswer = "keine Antwort"
        ok = "Ergebnis: DNS-Filter aktiv ({0}/{1} blockiert)."
        part = "Ergebnis: teilweise aktiv ({0}/{1}). Filterlisten in der FRITZ!Box aktualisieren."
        none = "Ergebnis: nicht aktiv. Siehe README, Abschnitt Fehlerbehebung."
        ctrl = "Warnung: Die Gegenprobe ist fehlgeschlagen. Normale Domains werden nicht aufgelöst."
    }
    en = @{
        server = "DNS server : {0}"; list = "Filter list: {0}"
        nolist = "Could not read test domains from the filter list."
        loadfail = "Could not load filter list: {0}"
        hblock = "Expected: blocked"; hallow = "Expected: reachable (cross-check)"; noanswer = "no answer"
        ok = "Result: DNS filter active ({0}/{1} blocked)."
        part = "Result: partially active ({0}/{1}). Update the filter lists in the FRITZ!Box."
        none = "Result: not active. See README, section Troubleshooting."
        ctrl = "Warning: cross-check failed. Regular domains are not resolved."
    }
}[$Lang]

$ControlDomains = @("wikipedia.org", "fritz.com")

Write-Host ($M.server -f $Server)
Write-Host ($M.list -f $ListUrl)
Write-Host ""

try {
    $raw = (Invoke-WebRequest -Uri $ListUrl -UseBasicParsing -TimeoutSec 30).Content
} catch {
    Write-Host ($M.loadfail -f $_.Exception.Message)
    exit 2
}

$domains = @($raw -split "`n" |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") -and -not $_.StartsWith("!") } |
    ForEach-Object { $_ -replace '^\*\.', '' } |
    Select-Object -First $Count)

if ($domains.Count -eq 0) { Write-Host $M.nolist; exit 2 }

function Resolve-One([string]$Name) {
    try {
        $r = Resolve-DnsName -Name $Name -Server $Server -Type A -DnsOnly -QuickTimeout -ErrorAction Stop
        ($r | Where-Object { $_.IPAddress } | Select-Object -First 1).IPAddress
    } catch { $null }
}

$blocked = 0
Write-Host $M.hblock
foreach ($d in $domains) {
    $ip = Resolve-One $d
    if (-not $ip -or $ip -eq "0.0.0.0") {
        Write-Host ("  [ OK ] {0,-48} {1}" -f $d, $(if ($ip) { $ip } else { $M.noanswer }))
        $blocked++
    } else {
        Write-Host ("  [FAIL] {0,-48} {1}" -f $d, $ip)
    }
}

Write-Host ""
Write-Host $M.hallow
$controlOk = $true
foreach ($d in $ControlDomains) {
    $ip = Resolve-One $d
    if ($ip -and $ip -ne "0.0.0.0") {
        Write-Host ("  [ OK ] {0,-48} {1}" -f $d, $ip)
    } else {
        Write-Host ("  [FAIL] {0,-48} {1}" -f $d, $M.noanswer)
        $controlOk = $false
    }
}

Write-Host ""
if (-not $controlOk) { Write-Host $M.ctrl }
if ($blocked -eq $domains.Count -and $controlOk) { Write-Host ($M.ok -f $blocked, $domains.Count); exit 0 }
elseif ($blocked -gt 0) { Write-Host ($M.part -f $blocked, $domains.Count); exit 1 }
else { Write-Host $M.none; exit 1 }
