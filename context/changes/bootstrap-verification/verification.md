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
deploy_plan_at: 2026-06-04T12:00:00Z
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

**MySQL** on every environment (local Compose, Railway staging, dedyk production). **MVP/staging: Railway** (managed MySQL, Redis, worker, cron). **Production: dedicated server + Docker Compose**. Full decision: `@context/foundation/infrastructure.md`. Deploy runbook: `@context/deployment/deploy-plan.md`.

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

**Docker / Railway**: scaffolded in commit `c529067`; live Railway deploy pending login + GitHub push — see deploy-plan.

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
| ci_provider                | github-actions                     | github-actions (tests later; deploy via Railway GitHub) |
| ci_default_flow            | auto-deploy-on-merge               | auto-deploy-on-merge (Railway on push to main) |
| has_auth                   | true                               | true                               |
| has_payments               | false                              | false                              |
| has_realtime               | false                              | false                              |
| has_ai                     | true                               | true                               |
| has_background_jobs        | true                               | true                               |

## Gaps and follow-up

| Gap | Status | Action |
| --- | ------ | ------ |
| Infrastructure platform choice | **Fixed** | `context/foundation/infrastructure.md` |
| Docker / Compose in repo | **Done** | `Dockerfile`, `docker-compose.yml` (commit `c529067`) |
| Railway deploy plan | **Done** | `context/deployment/deploy-plan.md` |
| Railway project live | **Open** | `railway login`, push to GitHub, connect repo — `@context/deployment/deploy-plan.md` |
| Host PHP 7.4 vs Laravel 13 | **Open** | Use `docker compose exec app php artisan …` |
| Fly.io deploy | **Superseded** | PaaS fallback only |
| Postgres on staging | **Avoided** | Railway **MySQL** only |
| `AGENTS.md` | **Done** | Repo root |

Recommended Compose services: **app**, **nginx**, **mysql**, **redis**, **queue**, **scheduler**.

## Next steps

1. `git remote add origin <url>` && `git push -u origin main`
2. `npx @railway/cli login` && `./scripts/railway-staging-setup.sh`
3. Railway canvas: MySQL + Redis + app/worker/cron — deploy-plan checklist
4. Connect GitHub on Railway `app` service (auto-deploy on `main`)
5. Run verification checklist in deploy-plan; record staging URL
