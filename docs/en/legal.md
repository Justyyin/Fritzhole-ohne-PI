# Legal notes

[Deutsch](../de/rechtliches.md)

These notes summarise general information on the legal situation in Germany (as of October 2026). They do not constitute legal advice. The situation in other countries may differ. For specific questions, consult a lawyer or a consumer advice centre.

## 1. Legality of ad blockers

- In its judgment of 19 April 2018 (I ZR 154/16, "Werbeblocker II"), the German Federal Court of Justice ruled that offering an ad blocker constitutes neither targeted obstruction nor an unlawful aggressive practice under the German Unfair Competition Act. The decision not to display ads is made by the user.
- A later copyright case concerning browser extensions was referred back for a new hearing by the court in 2025 and had not been finally decided at the time of research. It concerns providers of browser extensions, not private users.
- A DNS filter does not modify any website code. It merely does not answer name queries within the user's own network. Technically this is equivalent to a hosts file or the parental control filters routers have offered for years.
- The terms of use of individual services may prohibit ad blockers. A breach is generally not a violation of law but may result in access being blocked or the service being restricted.

## 2. Data protection

| Situation | Assessment |
|---|---|
| Filtering within the own household | household exemption under Art. 2(2)(c) GDPR |
| FRITZ!Box DNS filter | according to available information, no query log is kept and no browsing logs are created on the router |
| Public filtering DNS as upstream | all DNS queries are sent to the provider. Review the privacy policy and prefer providers based in the EEA. |
| Downloading filter lists | the public IP address of the connection is transmitted to the CDN operator, as with any website visit |

Solutions such as Pi-hole or AdGuard Home log every query per device by default. If shared with other adults, this should be disclosed.

## 3. Guests, housemates and family

According to the manufacturer, the DNS filter also applies to the guest network. An exception for the guest network is currently not available.

Recommendations:

- Inform housemates and adult household members that the filter is active.
- Add a note to the guest Wi-Fi information, for example: "This Wi-Fi filters known advertising, tracking and malware domains."
- For children, the DNS filter complements parental controls via access profiles but does not replace supervision.

Commercial offerings (holiday rentals, hospitality, offices, employers) are subject to further obligations, including under German telecommunications and data protection law, employment law and, where applicable, co-determination rights. These cases are not covered by this documentation.

## 4. FRITZ! Lab

- Downloading and using a Lab version is subject to the FRITZ! Lab terms of use.
- Lab versions are test software. Bugs are possible and use is at your own risk.
- The Lab version is provided by the manufacturer and is not third-party firmware. Returning to the release version is supported.
- For devices rented or leased from the internet provider, check the contractual terms. Some providers manage the firmware themselves or prohibit changes.

## 5. Screenshots

The screenshots in `docs/img/` show the FRITZ!OS user interface. The rights to the interface belong to FRITZ! GmbH. The screenshots are not covered by the CC BY license of this repository and are used solely for documentation purposes. Before publishing your own screenshots, remove personal and device-specific data (device names, IP and MAC addresses, Wi-Fi names, phone numbers, MyFRITZ! addresses).

## 6. Filter lists

- This repository links to filter lists. It does not copy or redistribute them.
- The lists from [hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists) are licensed under GPL-3.0. Anyone modifying or redistributing the lists must comply with the GPL-3.0.
- Other lists are subject to their own licenses.

## 7. Trademarks

FRITZ!, FRITZ!Box, FRITZ!OS and MyFRITZ! are trademarks of FRITZ! GmbH. Pi-hole, AdGuard and Mullvad are trademarks or names of their respective owners. They are mentioned for descriptive purposes only. There is no affiliation with the companies and projects named.

## 8. Liability

The content is provided without warranty. No liability is accepted for data loss, outages, unreachable services or missed calls, including emergency calls. Create a backup before making any change.

## 9. Notes on publishing a fork

- Do not commit backup files (`*.export`), passwords, serial numbers or unedited screenshots. The included `.gitignore` excludes typical files.
- For a commercial website operated from Germany, check the legal notice obligation under Section 5 of the German Digital Services Act (DDG). A purely private repository is generally not affected.
