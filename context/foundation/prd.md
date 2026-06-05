---
project: Deweloper Partner
version: 1
status: draft
created: 2026-05-24
context_type: greenfield
product_type: web-app
target_scale:
  users: large
  qps: null
  data_volume: null
timeline_budget:
  mvp_weeks: 6
  hard_deadline: null
  after_hours_only: true
---

## Vision & Problem Statement

Mały i średni deweloper musi regularnie przygotowywać oraz udostępniać dane cenowe zgodne z wymogami ustawy deweloperskiej — w szczególności art. 19b dotyczącym codziennego przekazywania danych o cenach oraz innymi obowiązkami jawności cen. Ręczne prowadzenie cenników, historii zmian, plików XML i publikacji na stronie WWW jest czasochłonne, podatne na błędy i trudne do udokumentowania w razie kontroli. Koszt status quo to godziny pracy administracyjnej, ryzyko błędów regulacyjnych oraz brak pewności, że publikacja jest kompletna i audytowalna.

Rynek nie oferuje prostego, gotowego workflow łączącego XML, historię cen, embed na stronie i audyt w jednym narzędziu skrojonym pod niszową, czasowo wrażliwą regulację polską — Deweloper Partner pakuje ten workflow w self-service SaaS. System rządowy pobiera aktualizacje samodzielnie (model pull) z plików XML i MD5 udostępnionych pod stałymi adresami HTTPS — deweloper nie wysyła raportu ręcznie do urzędu. Przy skali setek do tysięcy deweloperów reguła „codzienna aktualizacja plików pod stałym URL + odświeżenie przy każdej zmianie ceny” wymaga niezawodnej izolacji tenantów i przewidywalnej publikacji HTTPS.

## User & Persona

**Primary persona:** Właściciel lub office manager małego/średniego dewelopera, który samodzielnie zarządza jedną lub wieloma inwestycjami i odpowiada za zgodność publikacji cen z ustawą.

**Context:** Firma bez dedykowanego działu IT; ceny i oferta lokali aktualizowane ręcznie lub przez biuro obsługi inwestycji.

**Moment:** Przy każdej zmianie ceny lokalu, przed publikacją cennika, lub gdy zbliża się obowiązek codziennego przekazania danych — potrzebuje szybko zaktualizować dane, wygenerować XML i opublikować tabelę bez angażowania programisty.

## Success Criteria

### Primary

End-to-end compliance flow for one investment:

1. Admin rejestruje konto firmy i loguje się.
2. Tworzy inwestycję w panelu administracyjnym.
3. Dodaje lokale ręcznie **lub** importuje z Excel/CSV.
4. Aktualizuje dane lokalu (cena, metraż, pokoje, piętro, status, cena za m², data obowiązywania ceny).
5. System automatycznie zapisuje historię zmian cen.
6. System generuje plik XML zgodny ze schematem XSD `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd` oraz towarzyszący plik MD5 z sumą kontrolną.
7. Oba pliki są publicznie dostępne pod stałymi adresami HTTPS — system rządowy pobiera stamtąd aktualizacje (model pull).
8. System codziennie odświeża pliki raportu (XML + MD5) zgodnie z art. 19b — także gdy w danym dniu nie było zmian cen.
9. Wszystkie ceny w raporcie mają status „Opublikowany” (Published) zanim trafią do pliku XML.
10. Admin kopiuje kod embed i osadza tabelę cen na stronie dewelopera.
11. Odwiedzający widzi publiczną tabelę lokali z filtrowaniem i historią cen.
12. Panel walidacji pokazuje braki w wymaganych danych (w tym ceny brutto, pomieszczenia przynależne, inne świadczenia pieniężne).
13. Dziennik zmian rejestruje kto, kiedy i co zmienił.
14. Admin może korzystać z chatu AI w panelu, aby uzyskać wsparcie w workflow zgodności i wymaganych danych.

**Out of v1 scope (scoped down):** formularz leadowy, statystyki zainteresowania.

### Secondary

- Import lokali i cen z Excel/CSV działa niezawodnie dla typowego arkusza dewelopera — onboarding bez ręcznego przepisywania dziesiątek lokali.

### Guardrails

- Historia zmian cen jest niezmienialna i audytowalna — każda zmiana ceny ma timestamp i autora; brak cichego usuwania wpisów.
- Adresy URL plików XML i MD5 pozostają stałe po każdej aktualizacji — system rządowy i inne konsumenty nie tracą dostępu do tych samych adresów.
- Pliki raportu (XML, MD5) są dostępne wyłącznie przez HTTPS; formaty graficzne (PDF, JPG, PNG) nie są używane w raportowaniu do portalu — wyłącznie formaty maszynowo przetwarzalne (XML w MVP).
- Plik MD5 jest regenerowany przy każdej aktualizacji pliku XML.
- Wygenerowany XML musi przejść walidację względem XSD: `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd`.
- Do raportu portalowego trafiają wyłącznie rekordy ze statusem „Opublikowany” (Published).

## User Stories

### US-01: Deweloper publishes compliant prices for a new investment

- **Given** a registered admin with a new investment and no units yet
- **When** they import units from Excel, fix validation gaps shown in the panel, and publish
- **Then** the public price table shows all units with current prices and history, and the XML + MD5 files are available at stable HTTPS URLs

#### Acceptance Criteria

- Import accepts a typical developer spreadsheet format without manual field mapping in v1
- Validation panel lists specific missing fields per unit before publication is considered complete
- XML and MD5 URLs remain the same after subsequent price updates
- XML validates against `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd`
- Each imported/edited price appears in the unit's change history with timestamp
- Only records with status „Opublikowany” (Published) appear in the XML report file

### US-02: Government system pulls daily compliance report via stable HTTPS URLs

- **Given** an investment with published unit data and configured daily schedule
- **When** the calendar day ends without any price changes
- **Then** the system still refreshes the XML and MD5 files at the same stable HTTPS URLs and records the run in the audit log

#### Acceptance Criteria

- Daily refresh runs even when no prices changed that day
- XML and MD5 remain publicly accessible via HTTPS at unchanged URLs
- Government portal can pull current data without developer manual submission
- Each daily run is logged with timestamp and success/failure status
- Admin can view history of daily report runs per investment

### US-03: Admin uses AI chat for compliance guidance

- **Given** a logged-in admin with an investment that has validation gaps
- **When** they ask the in-app AI assistant what data is missing for publication
- **Then** the assistant responds with workflow guidance based on the product knowledge base and points to specific validation gaps

#### Acceptance Criteria

- AI chat is available only to authenticated admins
- Assistant references compliance workflow and required fields, not binding legal interpretation
- Responses align with validation panel state where applicable

## Functional Requirements

### Account & access

- FR-001: Admin can register a company account with email and password. Priority: must-have
  > Socrates: Counter-argument considered: registration friction delays time-to-value.
  > Resolution: kept; v1 includes guided onboarding wizard to minimize setup steps.
- FR-002: Admin can invite members to the company account. Priority: nice-to-have
  > Socrates: Counter-argument considered: invitation flow adds disproportionate MVP complexity.
  > Resolution: deferred to v2; v1 is admin-only.
- FR-003: Member can log in and access assigned investments. Priority: nice-to-have
  > Socrates: Counter-argument considered: member access depends on invite flow (FR-002).
  > Resolution: deferred to v2 alongside FR-002.

### Investments & units

- FR-004: Admin can create an investment in the admin panel. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-005: Admin can add units manually with required fields: unit number, usable area (m²), rooms, floor, status, gross price (cena brutto), gross price per m² (cena brutto za 1 m²), price effective date, ancillary space prices (parking, storage/komórki), and other monetary benefits payable to the developer. Priority: must-have
  > Socrates: Counter-argument considered: expanded field set increases MVP form complexity.
  > Resolution: kept; ustawa wymaga pełnego zakresu danych w raporcie portalowym — brak tych pól uniemożliwia zgodną publikację.
- FR-006: Admin can import units and prices from Excel/CSV. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-007: Admin can edit unit data fields. Priority: must-have
  > Socrates: No counter-argument; it stands as written.

### Price history & audit

- FR-008: System automatically records price change history for each unit on every price update. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-009: Admin can view an audit log showing who changed what and when. Priority: must-have
  > Socrates: No counter-argument; it stands as written.

### Publication & compliance

- FR-010: System generates an XML cennik file whose structure validates against the current `otwarte_dane` XSD schema published at `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd`, using only Published investment data. Priority: must-have
  > Socrates: No counter-argument; schema URL is the canonical regulator source on dane.gov.pl.
- FR-011: System generates an MD5 checksum file alongside the XML and serves both files at stable HTTPS URLs per investment, publicly accessible for government pull. Priority: must-have
  > Socrates: Counter-argument considered: MD5 adds a second artifact to maintain.
  > Resolution: kept; wymóg ustawowy — plik MD5 z sumą kontrolną jest obowiązkowy obok XML.
- FR-012: Admin can copy an embed code to display the price table on an external website. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-013: Public visitor can view a price table with filtering and per-unit price history. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-014: Admin can see a validation panel showing data completeness gaps against legal requirements (including gross prices, ancillary spaces, and other monetary benefits). Priority: must-have
  > Socrates: Counter-argument considered: manual checklist beats automated legal validation in v1.
  > Resolution: kept as checklist-style completeness UI; not a legal certification engine.
- FR-015: System retains investment and price data for the legally required minimum period. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-016: System refreshes the XML and MD5 report files daily on a scheduled basis at the same stable HTTPS URLs, regardless of whether prices changed that day, so the government system can pull current art. 19b data. Priority: must-have
  > Socrates: Counter-argument considered: on-demand regeneration on price change may suffice without a daily job.
  > Resolution: kept; art. 19b wymaga codziennego przekazywania danych — pliki muszą być aktualne każdego dnia, także bez zmian cen.
- FR-018: Admin can set price record status to „Opublikowany” (Published); only Published records are included in the XML report file served to the government portal. Priority: must-have
  > Socrates: No counter-argument; status Published is a legal requirement for portal visibility.
- FR-017: Admin can use an in-app AI chat assistant for guidance on compliance workflow, required data fields, and ustawa deweloperska context loaded into the product knowledge base. Priority: must-have
  > Socrates: Counter-argument considered: AI legal interpretation creates liability and was previously scoped out.
  > Resolution: kept as operational compliance assistant — helps complete data and understand workflow; does not provide binding legal advice (see Non-Goals).

## Non-Functional Requirements

- Admin panel edits feel instantaneous to the user (perceived response under 800 ms for field saves); public price table renders within 3 seconds on a typical Polish broadband connection.
- Price change history and audit log entries cannot be altered or deleted by any user, including admin — append-only by product guarantee.
- Daily compliance report refresh (FR-016) runs on a reliable schedule with auditable success/failure status per investment; missed runs are visible to admin.
- Report files (XML, MD5) are served over HTTPS only; response times must support reliable government pull (target: files available within 3 seconds on typical Polish broadband).
- Generated XML is validated against the XSD at `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd` before publication; validation failures block publish and surface in the admin validation panel. The `_latest` alias always resolves to the current regulator schema — implementation should re-fetch and re-validate when dane.gov.pl publishes schema updates.

## Business Logic

Raportowanie do portalu rządowego działa w modelu **pull**: Deweloper Partner hostuje pliki XML i MD5 pod stałymi adresami HTTPS (w imieniu dewelopera — SaaS eliminuje konieczność własnego serwera). System rządowy sam pobiera aktualizacje; deweloper nie wysyła raportu ręcznie do urzędu w MVP.

Każda zmiana ceny tworzy niezmiennialny wpis historii i wyzwala regenerację plików XML + MD5 oraz odświeżenie embedowalnej tabeli cen pod stałymi URL. Niezależnie od zmian cen, codzienny harmonogram odświeża te same pliki (XML + MD5) pod tymi samymi adresami HTTPS — spełniając wymóg art. 19b codziennego przekazywania danych, także w dniach bez aktualizacji cen.

Do pliku XML trafiają wyłącznie rekordy ze statusem „Opublikowany” (Published). Plik XML musi być zgodny ze schematem XSD `otwarte_dane` dostępnym pod adresem `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd` i zawierać: cenę brutto za lokal, cenę brutto za 1 m² powierzchni użytkowej, ceny pomieszczeń przynależnych (miejsca postojowe, komórki) oraz wszelkie inne świadczenia pieniężne na rzecz dewelopera. Obok XML generowany jest plik MD5 z sumą kontrolną. Formaty graficzne (PDF, JPG, PNG) nie są używane w raportowaniu portalowym.

When an admin updates a unit's price or price-effective date, the system records the prior value with timestamp and author, then refreshes the XML, MD5, and public price table so external consumers always see current data at the same URLs. The admin encounters this rule through automatic history entries after each save and through the validation checklist that highlights units not yet ready for complete disclosure. The daily job re-confirms file availability and logs each run in the audit trail.

Inputs consumed: gross prices, ancillary space prices, other monetary benefits, price-effective date, publication status, and required unit metadata fields. Output: updated XML + MD5 at stable HTTPS URLs, embeddable price table, and append-only history. The user sees history on each unit, the validation panel before considering publication complete, stable HTTPS URLs that update in place, and a log of daily report refresh runs.

## Access Control

- **Auth model:** Email + password login (standard SaaS).
- **Roles (v1):**
  - **Admin** — single role in MVP; full access to company account, investments, and units.
- **Roles (v2 — deferred):** Member role with scoped investment access and admin invite flow (FR-002, FR-003).
- **Sign-up:** Rejestracja firmy deweloperskiej przez admina; guided onboarding wizard to reduce time-to-value.
- **Public routes:** Publiczna tabela cen (embed + standalone URL), pliki XML i MD5 raportu (HTTPS, stałe URL) — bez logowania; dostępne dla systemu rządowego (pull).
- **Gated routes:** Panel administracyjny, import, walidacja, dziennik zmian, chat AI, historia raportów dziennych — wymagają zalogowania admina.

## Non-Goals

- **Graphic formats for portal reporting (PDF, JPG, PNG)** — portal wymaga formatów maszynowo przetwarzalnych; w MVP raport to XML + MD5.
- **Manual submission of reports to urząd** — system rządowy pobiera dane samodzielnie z publicznych URL HTTPS; brak push API / e-mail do urzędu w v1.
- **Public API for external systems** — v1 uses embed + stable HTTPS URLs (XML, MD5); REST API is a v2+ extension.
- **CRM, ERP, Otodom, OLX, and portal integrations** — out of scope; stable HTTPS URLs + embed cover MVP compliance needs.
- **Binding legal advice via AI** — AI chat (FR-017) assists with compliance workflow and data completeness; it does not replace legal counsel or provide authoritative interpretation of ustawa deweloperska.
- **Enterprise packages and custom per-client integrations** — MVP targets SMB self-service onboarding.
- **Lead form and engagement stats** — scoped out of v1 compliance core; deferred to v2.
- **Multi-user member invites (FR-002/FR-003)** — v1 is admin-only; team access in v2.
- **Generated investment website** — embed table on existing site, not a full site builder.
- **Mobile apps** — web-responsive admin and public table only.
- **Marketplace, online payments, reservation cart** — not a sales platform in v1.
- **Advanced CRM, competition monitoring, interactive map generation** — future roadmap items from idea-notes.

## Open Questions

1. **What is the canonical Excel/CSV import format?** — Owner: user. Needed to define FR-006 acceptance criteria and US-01 import behavior. Block: no (manual entry fallback exists).
2. **What is the legally required minimum data retention period (FR-015)?** — Owner: user / legal review. Block: yes for FR-015 implementation.
3. **What are target QPS and data volume at scale?** — Owner: user. `target_scale.qps` and `target_scale.data_volume` unset; needed before infrastructure sizing. Block: no at MVP, yes before large-scale launch.
4. **What knowledge base scope feeds the AI chat (FR-017)?** — Owner: user. Needed to define assistant boundaries and guardrails. Block: no.
