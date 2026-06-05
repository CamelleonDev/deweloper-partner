---
project: Deweloper Partner
context_type: greenfield
created: 2026-05-19
updated: 2026-05-19
timeline_budget:
  mvp_weeks: 6
  hard_deadline: null
  after_hours_only: true
product_type: web-app
target_scale:
  users: large
  qps: null
  data_volume: null
checkpoint:
  current_phase: 8
  phases_completed: [1, 2, 3, 4, 5, 6, 7]
  gray_areas_resolved:
    - topic: pain category
      decision: regulatory compliance pressure (art. 19b jawność cen)
    - topic: insight
      decision: bundled compliance workflow for a niche, time-sensitive regulation
    - topic: primary persona scope
      decision: owner or office manager at a small/medium dew firm
    - topic: auth strategy
      decision: email + password login
    - topic: role model
      decision: admin-only for v1; member invites deferred to v2 (Socrates FR-002)
  frs_drafted: 15
  quality_check_status: accepted
---

## Vision & Problem Statement

Mały i średni deweloper musi regularnie przygotowywać oraz udostępniać dane cenowe zgodne z wymogami ustawy deweloperskiej — w szczególności art. 19b dotyczącym codziennego przekazywania danych o cenach oraz innymi obowiązkami jawności cen.

Ręczne prowadzenie cenników, historii zmian, plików XML i publikacji na stronie WWW jest czasochłonne, podatne na błędy i trudne do udokumentowania w razie kontroli. Koszt status quo to godziny pracy administracyjnej, ryzyko błędów regulacyjnych oraz brak pewności, że publikacja jest kompletna i audytowalna.

**Insight:** Rynek nie oferuje prostego, gotowego workflow łączącego XML, historię cen, embed na stronie i audyt w jednym narzędziu skrojonym pod niszową, czasowo wrażliwą regulację polską — Deweloper Partner pakuje ten workflow w self-service SaaS.

**Scale note (100x):** Przy setkach/tysiącach deweloperów reguła „każda zmiana ceny → odświeżenie XML i tabeli pod stałym URL” wymaga niezawodnej izolacji tenantów i przewidywalnej publikacji — bez zmiany logiki domenowej, ale z rosnącą wagą SLA publikacji.

## User & Persona

**Primary persona:** Właściciel lub office manager małego/średniego dewelopera, który samodzielnie zarządza jedną lub wieloma inwestycjami i odpowiada za zgodność publikacji cen z ustawą.

**Context:** Firma bez dedykowanego działu IT; ceny i oferta lokali aktualizowane ręcznie lub przez biuro obsługi inwestycji.

**Moment:** Przy każdej zmianie ceny lokalu, przed publikacją cennika, lub gdy zbliża się obowiązek codziennego przekazania danych — potrzebuje szybko zaktualizować dane, wygenerować XML i opublikować tabelę bez angażowania programisty.

## Access Control

- **Auth model:** Email + password login (standard SaaS).
- **Roles (v1):**
  - **Admin** — single role in MVP; full access to company account, investments, and units.
- **Roles (v2 — deferred):** Member role with scoped investment access and admin invite flow (FR-002, FR-003).
- **Sign-up:** Rejestracja firmy deweloperskiej przez admina; guided onboarding wizard to reduce time-to-value.
- **Public routes:** Publiczna tabela cen (embed + standalone URL) — bez logowania.
- **Gated routes:** Panel administracyjny, import, walidacja, dziennik zmian — wymagają zalogowania admina.

## Success Criteria

### Primary

End-to-end compliance flow for one investment:

1. Admin rejestruje konto firmy i loguje się.
2. Tworzy inwestycję w panelu administracyjnym.
3. Dodaje lokale ręcznie **lub** importuje z Excel/CSV.
4. Aktualizuje dane lokalu (cena, metraż, pokoje, piętro, status, cena za m², data obowiązywania ceny).
5. System automatycznie zapisuje historię zmian cen.
6. System generuje aktualny plik XML i udostępnia go pod stałym adresem URL.
7. Admin kopiuje kod embed i osadza tabelę cen na stronie dewelopera.
8. Odwiedzający widzi publiczną tabelę lokali z filtrowaniem i historią cen.
9. Panel walidacji pokazuje braki w wymaganych danych.
10. Dziennik zmian rejestruje kto, kiedy i co zmienił.

**Out of v1 scope (scoped down):** formularz leadowy, statystyki zainteresowania.

### Secondary

- Import lokali i cen z Excel/CSV działa niezawodnie dla typowego arkusza dewelopera — onboarding bez ręcznego przepisywania dziesiątek lokali.

### Guardrails

- Historia zmian cen jest niezmienialna i audytowalna — każda zmiana ceny ma timestamp i autora; brak cichego usuwania wpisów.
- Adres URL pliku XML pozostaje stały po aktualizacji cen — zewnętrzne systemy i regulator nie tracą dostępu do tego samego endpointu.

## Timeline acknowledgment

Acknowledged on 2026-05-19: 6-week MVP requires sustained dedication; user accepted after scoping down to compliance core (leads + stats deferred to v2).

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
- FR-005: Admin can add units manually with required fields (number, m², rooms, floor, status, price, price/m², price effective date). Priority: must-have
  > Socrates: No counter-argument; it stands as written.
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

- FR-010: System generates a current XML cennik file from investment data. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-011: System serves the XML file at a stable URL per investment. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-012: Admin can copy an embed code to display the price table on an external website. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-013: Public visitor can view a price table with filtering and per-unit price history. Priority: must-have
  > Socrates: No counter-argument; it stands as written.
- FR-014: Admin can see a validation panel showing data completeness gaps against legal requirements. Priority: must-have
  > Socrates: Counter-argument considered: manual checklist beats automated legal validation in v1.
  > Resolution: kept as checklist-style completeness UI; not a legal certification engine.
- FR-015: System retains investment and price data for the legally required minimum period. Priority: must-have
  > Socrates: No counter-argument; it stands as written.

## User Stories

### US-01: Developer publishes compliant prices for a new investment

- **Given** a registered admin with a new investment and no units yet
- **When** they import units from Excel, fix validation gaps shown in the panel, and publish
- **Then** the public price table shows all units with current prices and history, and the XML file is available at a stable URL

#### Acceptance Criteria

- Import accepts a typical developer spreadsheet format without manual field mapping in v1
- Validation panel lists specific missing fields per unit before publication is considered complete
- XML URL remains the same after subsequent price updates
- Each imported/edited price appears in the unit's change history with timestamp

## Business Logic

**Domain rule:** Every price change creates an immutable history entry and triggers regeneration of the legally required public price disclosure (XML file and embeddable price table) at stable URLs.

When an admin updates a unit's price or price-effective date, the system records the prior value with timestamp and author, then refreshes the XML cennik and public price table so external consumers always see current data at the same endpoints. The admin encounters this rule through automatic history entries after each save and through the validation checklist that highlights units not yet ready for complete disclosure.

Inputs consumed: unit price, price-effective date, and required unit metadata fields. Output: updated public disclosure artifacts plus append-only history. The user sees history on each unit, the validation panel before considering publication complete, and the stable XML/embed URLs that update in place.

## Non-Functional Requirements

- Admin panel edits feel instantaneous to the user (perceived response under 800 ms for field saves); public price table renders within 3 seconds on a typical Polish broadband connection.
- Price change history and audit log entries cannot be altered or deleted by any user, including admin — append-only by product guarantee.

## Non-Goals

- **Public API for external systems** — v1 uses embed + stable XML URL only; API is a v2+ extension.
- **CRM, ERP, Otodom, OLX, and portal integrations** — out of scope; manual export/embed is sufficient for MVP.
- **WordPress plugin** — embed code covers existing websites; native plugin deferred.
- **AI chat about ustawa deweloperska** — legal interpretation stays with the developer; no in-app legal AI.
- **Enterprise packages and custom per-client integrations** — MVP targets SMB self-service onboarding.
- **Lead form and engagement stats** — scoped out of v1 compliance core; deferred to v2.
- **Multi-user member invites (FR-002/FR-003)** — v1 is admin-only; team access in v2.
- **Generated investment website** — embed table on existing site, not a full site builder.
- **Mobile apps** — web-responsive admin and public table only.
- **Marketplace, online payments, reservation cart** — not a sales platform in v1.
- **Advanced CRM, competition monitoring, interactive map generation** — future roadmap items from idea-notes.

## Quality cross-check

All elements present — no gaps at handoff.

