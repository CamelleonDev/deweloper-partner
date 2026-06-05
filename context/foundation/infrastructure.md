---
project: deweloper-partner
researched_at: 2026-06-04T00:00:00Z
amended_at: 2026-06-04T12:00:00Z
recommended_platform: Hybrid — Railway + MySQL (MVP / staging) → dedyk Docker Compose + MySQL (production)
runner_up: Fly.io (region waw, PaaS fallback only)
context_type: mvp
tech_stack:
  language: PHP 8.3+
  framework: Laravel 13
  database: MySQL
  runtime: Docker (Compose locally and on dedyk; Nixpacks/Docker on Railway)
---

## Recommendation

**MVP and staging on Railway with managed MySQL; production on your dedicated server with Docker Compose and MySQL.**

Use **MySQL on every leg** (Railway staging, local Compose, dedyk prod) — not Postgres — so Laravel migrations and SQL behave identically when you cut over from staging to the dedyk. Railway canvas: web app, **MySQL**, Redis, queue worker, and cron (`php artisan schedule:run`) per [Railway Laravel guide](https://docs.railway.com/guides/laravel) (guide examples often show Postgres; choose **Add MySQL** on the canvas). Production reuses the same Compose topology as local dev (`@context/foundation/tech-stack.md`). Fly.io (`waw`) remains a PaaS fallback only if Railway EU routing or billing becomes a blocker.

## Platform Comparison

Hard filters applied before scoring:

- **Q1 (persistent processes):** dropped Vercel and Netlify — no always-on PHP workers / Laravel scheduler without separate paid worker services; poor fit for daily tenant batch jobs.
- **Tech stack (PHP / Laravel 13):** dropped Cloudflare Workers/Pages — JS/edge runtime, not full Laravel; Vercel/Netlify lack native PHP hosting.

| Platform | CLI-first | Managed | Agent docs | Deploy API | MCP / Integration | Total (Pass=1, Partial=0.5) |
|---|---|---|---|---|---|---|
| Cloudflare | Pass | Pass | Pass | Pass | Pass | **Filtered out** (no Laravel/PHP) |
| Vercel | Pass | Pass | Partial | Pass | Partial | **Filtered out** (no PHP) |
| Netlify | Pass | Pass | Partial | Pass | Pass | **Filtered out** (no PHP + no persistent workers) |
| **Railway** | Pass | Pass | Pass (`llms-full.txt`) | Pass | Partial | **4.5** |
| **Fly.io** | Pass | Pass | Pass (MDX on GitHub) | Pass | Partial | **4.5** |
| **Render** | Pass | Pass | Partial | Pass | Partial | **4.0** |
| **Self-host (dedyk)** | Partial | Fail (you operate OS/DB) | Partial (your runbooks) | Partial (Compose/SSH) | Fail | **Prod leg — Compose + MySQL** |
| **AWS (EC2/RDS etc.)** | Partial | Partial | Pass | Partial | Partial | **Out of MVP pool** — educational interest only; same ops burden as dedyk with more moving parts |

Interview weights: DX → Railway for co-located canvas; single region PL → dedyk prod + verify Railway DB region; co-location → Railway +1 on staging; self-host familiarity → production on dedyk, not PaaS lock-in.

### Shortlisted Platforms

#### 1. Hybrid — Railway + MySQL (MVP/staging) + dedyk Compose + MySQL (production) (Recommended)

**MVP/staging on Railway:** web, **MySQL** (Create → Database → Add MySQL), Redis, worker (`php artisan queue:work`), cron (`php artisan schedule:run`). Env: `DB_CONNECTION=mysql`, reference vars `${{MySQL.MYSQLHOST}}`, `${{MySQL.MYSQLPASSWORD}}`, etc. CLI: `railway init`, `railway up`. Docs: [llms-full.txt](https://docs.railway.com/llms-full.txt). Hobby ~$5/mo + usage ([pricing](https://docs.railway.com/pricing/plans)).

**Production on dedyk:** Docker Compose — PHP 8.4, nginx, **MySQL**, Redis, queue worker — matching local dev; PL data residency; ops on you.

#### 2. Fly.io

Laravel-first; region `waw`; `fly postgres` available but **avoid Postgres here** if prod is MySQL — use external MySQL or reconsider engine parity. Fallback if Railway blocks.

#### 3. Render

Docker Laravel; managed Postgres in docs — **poor MySQL parity fit** for this hybrid. Worker + cron need paid services; free Postgres deleted after 90 days.

## Anti-Bias Cross-Check: Hybrid (Railway MySQL → dedyk MySQL)

### Devil's Advocate — Weaknesses

1. **Two deployment paths** — Railway Nixpacks vs dedyk Compose can drift (PHP extensions, Redis drivers) unless one canonical `Dockerfile` is shared when possible.
2. **Railway ephemeral filesystem** — local `storage/` breaks on redeploy; use object storage (S3/R2) for uploads on the PaaS leg; bind mounts on dedyk prod.
3. **Daily compliance batch** — cron/worker misconfiguration on Railway or dedyk misses art. 19b daily XML refresh.
4. **Hybrid migration cost** — Railway MySQL dump → dedyk MySQL restore + DNS cutover easy to defer until painful.
5. **Agent ops on dedyk** — SSH/Compose rollback is manual; restrict agent to Railway staging + PRs only.

### Pre-Mortem — How This Could Fail

The team shipped on Railway with Nixpacks and **Postgres** while prod dedyk used **MySQL** — JSON queries and migration types diverged at cutover. Queue and daily XML jobs shared the web service; schedules slipped. Prod `.env` pointed Redis at `127.0.0.1` inside the container. Storage on Railway disk vanished on redeploy. GitHub Actions deployed staging but dedyk prod was updated by hand and stalled. Root cause: **no single DB engine and no canonical Compose artifact** across legs.

### Unknown Unknowns

- Railway private MySQL network is **unavailable during build** — run `php artisan migrate --force` in **Pre-Deploy**, not build ([Railway help](https://station.railway.com/questions/i-cannot-connect-to-the-postgres-service-3ee35563)).
- Railway does not deploy `docker-compose.yml` as a unit — mirror services on the canvas or one Dockerfile.
- Preview URLs may expose staging data — use synthetic tenants, not prod DB copies.
- Verify Railway MySQL region for data residency; dedyk prod gives explicit PL/UE control.
- SMTP remains external (Brevo/Postmark/etc.) on both legs.

## Operational Story

**Hybrid:** Railway + MySQL for MVP/staging; dedyk Compose + MySQL for production.

- **Preview deploys:** Railway GitHub integration or `railway up`; separate Railway project optional. No real tenant PII on preview.
- **Secrets:** Railway Variables (`DB_*`, `REDIS_*`, `APP_KEY`); GitHub `RAILWAY_TOKEN`. Dedyk — `.env` via `docker compose --env-file`; prod credentials not in git.
- **Rollback:** Railway — redeploy previous deployment. Dedyk — previous image tag + `docker compose up -d`; DB migrations may need snapshot restore.
- **Approval:** Human — dedyk prod deploy, DNS, destructive migrations, secret rotation. Agent — Railway staging, logs, deploy config PRs only.
- **Logs:** `railway logs` (staging); `docker compose logs -f app worker` (dedyk).

## Risk Register

| Risk | Source | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| Postgres/MySQL mismatch between legs | User decision / Pre-mortem | L | H | **MySQL only** on Railway, local, and dedyk — locked in `tech-stack.md` |
| PaaS vs dedyk config drift | Devil's advocate | M | H | Canonical `Dockerfile` + `docker-compose.yml`; Railway from Dockerfile when ready |
| Missed daily XML/cron job | Q1 / Devil's advocate | M | H | Dedicated Railway cron service; alert if last XML run > 25h |
| Railway ephemeral storage | Research | H | M | Object storage on PaaS; bind mount `storage/` on dedyk |
| Hybrid migration deferred | Pre-mortem | M | H | MySQL dump/restore checklist in `context/deployment/deploy-plan.md` |
| Agent SSH on production dedyk | Devil's advocate | M | H | CI-only prod deploy; agent limited to Railway staging |

## Getting Started

1. **Local Compose** — `docker-compose.yml`: PHP 8.4, nginx, **MySQL**, Redis, queue worker; `DB_CONNECTION=mysql`, `DB_HOST=mysql` (`@context/foundation/tech-stack.md`).
2. **Railway** — `npm i -g @railway/cli`; `railway login`; `railway init`; add **MySQL** + Redis; web + worker + cron services ([Laravel guide](https://docs.railway.com/guides/laravel)).
3. **Railway env** — `DB_CONNECTION=mysql`, `${{MySQL.MYSQLHOST}}`, `${{MySQL.MYSQLPORT}}`, `${{MySQL.MYSQLDATABASE}}`, `${{MySQL.MYSQLUSER}}`, `${{MySQL.MYSQLPASSWORD}}`; `QUEUE_CONNECTION=redis`; migrations in Pre-Deploy.
4. **GitHub Actions** — deploy to Railway on merge to `main` (staging); dedyk prod workflow separate with manual approval.
5. **Before dedyk prod** — close gaps in `@context/changes/bootstrap-verification/verification.md`; MySQL backup script; document cutover in `context/deployment/deploy-plan.md`.

## Out of Scope

- Docker/CI implementation detail (next: `/10x-implement` and deploy plan)
- Production HA / multi-region
- AWS — not scored in MVP pool; viable later (Lightsail, ECS + RDS MySQL) if dedyk is replaced
