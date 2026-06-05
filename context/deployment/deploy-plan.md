---
project: deweloper-partner
plan_approved_at: 2026-06-04
deploy_status: repo_ready_awaiting_platform
commit: c529067
platform: Railway + MySQL (staging MVP)
production_target: dedyk Docker Compose + MySQL (later)
---

# Deploy Plan — Railway Staging MVP

## Decision summary

| Leg | Platform | Database |
|-----|----------|----------|
| Staging / MVP | Railway | MySQL (managed) |
| Production (later) | Dedicated server | MySQL (Compose) |

Auto-deploy: **Railway GitHub integration** on `main` (not GitHub Actions deploy workflow).

## Repo artifacts (done)

| Artifact | Purpose |
|----------|---------|
| [`Dockerfile`](../Dockerfile) | Targets `web` (nginx+php-fpm) and `cli` (worker/cron) |
| [`docker-compose.yml`](../docker-compose.yml) | Local parity: app, nginx, mysql, redis, queue, scheduler |
| [`railway.toml`](../railway.toml) | Web service: Dockerfile target `web`, pre-deploy migrations |
| [`railway/init-app.sh`](../railway/init-app.sh) | Pre-deploy: cache + migrate + storage:link |
| [`railway/run-worker.sh`](../railway/run-worker.sh) | Queue worker |
| [`railway/run-cron.sh`](../railway/run-cron.sh) | Laravel scheduler (every minute) |
| [`scripts/railway-staging-setup.sh`](../scripts/railway-staging-setup.sh) | Post-login checklist script |

Initial commit: `c529067` — `feat: add Docker Compose and Railway staging configuration`

## Manual gates (required before live deploy)

### 1. GitHub push

```bash
git remote add origin git@github.com:<org>/deweloper-partner.git
git push -u origin main
```

### 2. Railway login

```bash
npx @railway/cli login
./scripts/railway-staging-setup.sh
```

### 3. Railway canvas services

| Service | Type | Config |
|---------|------|--------|
| `MySQL` | Database → Add MySQL | Not Postgres |
| `Redis` | Database / Redis | Sessions, cache, queue |
| `app` | GitHub + Dockerfile | `railway.toml`; health `/up` |
| `worker` | Same repo, target `cli` | Start: `./railway/run-worker.sh` |
| `cron` | Cron job `*/1 * * * *` | Start: `./railway/run-cron.sh` |

### 4. Environment variables (shared)

Set in Railway Variables (Raw Editor). Generate key locally:

```bash
php artisan key:generate --show   # requires PHP 8.4+
```

| Variable | Value |
|----------|-------|
| `APP_ENV` | `production` |
| `APP_DEBUG` | `false` |
| `APP_KEY` | from key:generate |
| `APP_URL` | `https://<app>.up.railway.app` |
| `DB_CONNECTION` | `mysql` |
| `DB_HOST` | `${{MySQL.MYSQLHOST}}` |
| `DB_PORT` | `${{MySQL.MYSQLPORT}}` |
| `DB_DATABASE` | `${{MySQL.MYSQLDATABASE}}` |
| `DB_USERNAME` | `${{MySQL.MYSQLUSER}}` |
| `DB_PASSWORD` | `${{MySQL.MYSQLPASSWORD}}` |
| `REDIS_HOST` | `${{Redis.REDISHOST}}` |
| `REDIS_PORT` | `${{Redis.REDISPORT}}` |
| `REDIS_PASSWORD` | `${{Redis.REDIS_PASSWORD}}` |
| `QUEUE_CONNECTION` | `redis` |
| `CACHE_STORE` | `redis` |
| `SESSION_DRIVER` | `redis` |

**Critical:** migrations run in **Pre-Deploy** (`railway.toml`), not during Docker build — MySQL private network is unavailable at build time.

### 5. GitHub → Railway auto-deploy

1. Railway → `app` service → Settings → Connect Repo
2. Select repo + branch `main`
3. Enable **Deploy on push**
4. Do **not** add `.github/workflows/railway-deploy.yml`

## Verification checklist (after first deploy)

| Check | Command / URL | Expected |
|-------|---------------|----------|
| Home | `GET /` | HTTP 200, Laravel welcome |
| Health | `GET /up` | OK |
| App logs | `npx @railway/cli logs` | No DB connection errors |
| MySQL | Railway MySQL metrics | `users`, `cache`, `jobs` tables |
| Worker | worker service logs | `Processing jobs` / idle, no crash loop |
| Cron | cron service logs | `schedule:run` every minute |
| HTTPS | Browser | Valid cert, no mixed content |

Record staging URL here after deploy: `________________________`

## Rollback

- Railway Dashboard → Deployments → Redeploy previous successful deployment
- CLI: `npx @railway/cli redeploy`

## Known MVP limitations

- **Ephemeral disk** on Railway — `storage/` uploads lost on redeploy; use S3/R2 before prod
- **Mail** — `MAIL_MAILER=log`; no real auth email yet
- **Three compute services** — app + worker + cron billing

## Next steps (post-staging)

1. Local smoke: `docker compose up -d` with `.env` MySQL profile
2. Object storage for tenant uploads (Railway + prod)
3. Dedyk prod cutover: MySQL dump/restore, DNS, CI deploy with human approval
4. Optional GHA workflow for `composer test` only (no deploy)

## Execution log

| Step | Owner | Status | Notes |
|------|-------|--------|-------|
| Docker + Railway config in repo | Agent | Done | commit `c529067` |
| `railway login` | Human | Pending | No `~/.railway` token found |
| Git push to GitHub | Human | Blocked | Remote `git@github.com:kamilkowalski/deweloper-partner.git` added; push failed — SSH host key for github.com (fix `known_hosts` or use HTTPS remote) |
| Railway project + MySQL + Redis | Human | Pending | After login |
| GitHub connect + first deploy | Human | Pending | After push |
| Verification checklist | Human | Pending | Fill staging URL above |
