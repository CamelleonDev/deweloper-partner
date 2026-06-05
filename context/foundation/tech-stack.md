---
starter_id: laravel
package_manager: composer
project_name: deweloper-partner
hints:
  language_family: php
  team_size: solo
  deployment_target: self-host
  staging_platform: railway
  database: mysql
  ci_provider: github-actions
  ci_default_flow: auto-deploy-on-merge
  bootstrapper_confidence: verified
  path_taken: standard
  quality_override: false
  self_check_answers: null
  has_auth: true
  has_payments: false
  has_realtime: false
  has_ai: true
  has_background_jobs: true
---

## Why this stack

Deweloper Partner is a PHP multi-tenant SaaS with auth, Excel/CSV import, queues, and AI chat. Laravel remains the application framework.

**Database: MySQL everywhere** — local Compose, Railway (MVP/staging), and production on the dedicated server use the same engine so migrations and queries do not diverge between environments.

**Local dev and production parity: Docker Compose** (PHP 8.4 app, web server, **MySQL**, Redis for queues/cache) on the dedicated server; avoids host PHP version drift (e.g. system PHP 7.4 vs Laravel 13).

**MVP/staging: Railway** — managed MySQL + Redis, web/worker/cron services on one project canvas; GitHub Actions auto-deploy on merge to staging. See `@context/foundation/infrastructure.md`.

**Production: dedicated server + Docker Compose** — same stack shape as local; PL data residency and ops under your control. `deployment_target: self-host` records the prod leg.

Bootstrapper shipped plain Composer scaffold only — **Docker and Railway config are deliberate follow-ups**, not part of the Laravel starter CLI.
