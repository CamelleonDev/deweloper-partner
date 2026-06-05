# Repository Guidelines

Deweloper Partner is a Laravel 13 SaaS for Polish developer price compliance: multi-tenant units, XML + MD5 at stable HTTPS URLs, embed tables, audit log, AI chat. Stack: PHP 8.3+, Vite/Tailwind. Scope: `@context/foundation/prd.md`. Stack/Docker plan: `@context/foundation/tech-stack.md`.

## Hard rules

- Never commit `.env`, credentials, or `auth.json` — use `@.env.example`.
- Preserve `context/` (PRD, tech-stack, verification logs).
- Price history is append-only; no silent deletes of historical price rows (`@context/foundation/prd.md`).
- Portal XML: only Published units; validate XSD `https://www.dane.gov.pl/static/xml/otwarte_dane_latest.xsd`; keep XML/MD5 URL paths stable.
- Minimal diffs; no drive-by refactors; no git commits unless the user asks.
- `.cursor/` is gitignored — team rules live in this file and `context/`.

## Project structure

`app/` (PSR-4 `App\`), `routes/web.php`, `database/migrations`, `resources/` (Blade + Vite), `tests/Feature` and `tests/Unit`, `context/foundation/` (PRD, lessons), `context/changes/` (bootstrap log). Docker Compose is planned in tech-stack but not in the repo — use Composer/npm below.

## Build, test, and development

`composer setup` — install, `.env`, key, migrate, npm build (`@composer.json`).  
`composer dev` — serve, queue, pail, Vite concurrently.  
`composer test` — PHPUnit via `php artisan test` (in-memory SQLite: `@phpunit.xml`).  
`npm run dev` / `npm run build` — `@package.json`.  
Format PHP: `./vendor/bin/pint`.

## Coding style and testing

New web routes: add to `routes/web.php`. Migrations: `database/migrations/YYYY_MM_DD_HHMMSS_<snake_case>.php` (match existing files in `@database/migrations/`). PHPUnit 12: feature tests in `tests/Feature/`, unit in `tests/Unit/`; run `php artisan test --filter=ClassName`.

## Commits, PRs, security

No commits yet — use Conventional Commits (`feat:`, `fix:`) once history starts. CI workflows not added; run `composer test` and Pint before PR. Secrets only in `.env`. Post-bootstrap gaps: `@context/changes/bootstrap-verification/verification.md`.
