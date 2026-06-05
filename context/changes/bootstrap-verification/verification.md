---
bootstrapped_at: 2026-05-26T17:30:00Z
starter_id: laravel
starter_name: Laravel
project_name: deweloper-partner
language_family: php
package_manager: composer
cwd_strategy: subdir-then-move
bootstrapper_confidence: verified
phase_3_status: ok
audit_command: "null"
handoff_amended_at: 2026-05-26T18:00:00Z
infrastructure_decided_at: 2026-06-04T12:00:00Z
---

## Hand-off

```yaml
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
```

## Why this stack

Deweloper Partner is a PHP multi-tenant SaaS with auth, Excel/CSV import, queues, and AI chat. Laravel remains the application framework.

**MySQL** on every environment (local Compose, Railway staging, dedyk production). **MVP/staging: Railway** (managed MySQL, Redis, worker, cron). **Production: dedicated server + Docker Compose** (PHP 8.4, nginx, MySQL, Redis). Full decision: `@context/foundation/infrastructure.md`. Bootstrapper did not ship Docker or Railway config — follow-ups below.

## Pre-scaffold verification

| Signal             | Value                              | Severity | Notes                              |
| ------------------ | ---------------------------------- | -------- | ---------------------------------- |
| npm package        | not run                            | —        | PHP starter; no npm create-* CLI   |
| GitHub repo        | not run                            | —        | docs_url is https://laravel.com/docs (not a GitHub repo URL) |

Recency: no recency signal available for Laravel docs URL. Proceeding.

## Scaffold log

**Resolved invocation**: `composer create-project laravel/laravel .bootstrap-scaffold --no-interaction --prefer-dist`

**Strategy**: subdir-then-move

**Exit code**: 0

**Files moved**: 8642+ (including vendor/)

**Conflicts (.scaffold siblings)**: none

**.gitignore handling**: moved silently

**.bootstrap-scaffold cleanup**: deleted

**Notes**: Scaffold used PHP 8.4.14 (`/usr/local/Cellar/php/8.4.14_1/bin/php`) because system default `php` is 7.4.33, which does not satisfy Laravel 13's `>= 8.4.0` requirement. `context/` preserved verbatim.

**Docker / Railway**: not scaffolded. See **Gaps and follow-up**.

## Post-scaffold audit

**Tool**: skipped — no built-in audit tool for php

**Recommended external tool**: Roave Security Advisories Composer plugin or local-php-security-checker

## Hints recorded but not acted on

| Hint                       | Value (at bootstrap)               | Value (current hand-off)           |
| -------------------------- | ---------------------------------- | ---------------------------------- |
| bootstrapper_confidence    | verified                           | verified                           |
| quality_override           | false                              | false                              |
| path_taken                 | standard                           | standard                           |
| self_check_answers         | null                               | null                               |
| team_size                  | solo                               | solo                               |
| deployment_target          | fly                                | **self-host** (dedyk Compose prod) |
| staging_platform           | —                                  | **railway**                        |
| database                   | —                                  | **mysql**                          |
| ci_provider                | github-actions                     | github-actions                     |
| ci_default_flow            | auto-deploy-on-merge               | auto-deploy-on-merge (→ Railway staging) |
| has_auth                   | true                               | true                               |
| has_payments               | false                              | false                              |
| has_realtime               | false                              | false                              |
| has_ai                     | true                               | true                               |
| has_background_jobs        | true                               | true                               |

## Gaps and follow-up

| Gap | Status | Action |
| --- | ------ | ------ |
| Infrastructure platform choice | **Fixed** in `context/foundation/infrastructure.md` | Railway + MySQL (MVP/staging); dedyk Compose + MySQL (prod) |
| Docker / Compose not in repo | **Open** | Add `docker-compose.yml` + `Dockerfile`: app, nginx, **mysql**, redis, queue worker |
| Railway project / services | **Open** | MySQL + Redis on canvas; web, worker, cron; `DB_CONNECTION=mysql`; GitHub Actions → staging |
| No `Dockerfile` or `docker-compose.yml` in repo | **Open** | Same as above; align with `tech-stack.md` |
| Host PHP 7.4 vs Laravel 13 | **Open** | Prefer `docker compose exec` for `artisan` / `composer` |
| Fly.io deploy | **Superseded** | Fly remains PaaS fallback only (`infrastructure.md` runner-up) |
| Postgres as default in Railway docs | **N/A — avoided** | Use **MySQL** on Railway; do not use Postgres on staging |
| `AGENTS.md` | **Done** | Repo root onboarding doc exists |

Recommended Compose services: **app** (PHP 8.4), **web** (nginx), **mysql**, **redis**, **queue** (`php artisan queue:work`). Optional **scheduler** container or cron on dedyk for daily XML/MD5 batch.

## Next steps

1. Add `docker-compose.yml` (+ `Dockerfile`) with **MySQL** — `@context/foundation/tech-stack.md`.
2. Point `.env` at Docker hostnames (`DB_HOST=mysql`, `DB_CONNECTION=mysql`, `REDIS_HOST=redis`).
3. Provision Railway project: MySQL, Redis, web/worker/cron — `@context/foundation/infrastructure.md`.
4. GitHub Actions: auto-deploy to Railway on merge; separate approved workflow for dedyk prod later.
5. Document prod cutover in `context/deployment/deploy-plan.md` (MySQL dump/restore, DNS, rollback).
