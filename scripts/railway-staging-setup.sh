#!/usr/bin/env bash
# Run after: railway login && git remote add origin <url> && git push -u origin main
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

RAILWAY="${RAILWAY_CMD:-npx @railway/cli}"

echo "==> Checking Railway auth"
"$RAILWAY" whoami

echo "==> Linking Railway project (creates if needed)"
if [[ ! -f .railway/project.json ]]; then
  "$RAILWAY" init --name deweloper-partner-staging
fi

echo ""
echo "Manual steps in Railway Dashboard (CLI cannot add all plugins reliably):"
echo "  1. Project canvas → New → Database → MySQL"
echo "  2. Project canvas → New → Database → Redis"
echo "  3. Duplicate app service twice for worker + cron (or add empty services)"
echo ""
echo "Web service (app) — Settings:"
echo "  - Connect GitHub repo, branch main, Deploy on push"
echo "  - Builder: Dockerfile, target web (see railway.toml)"
echo "  - Pre-deploy: chmod +x ./railway/init-app.sh && ./railway/init-app.sh"
echo ""
echo "Worker service — Settings:"
echo "  - Same repo; Dockerfile target: cli"
echo "  - Start command: ./railway/run-worker.sh"
echo ""
echo "Cron service — Settings:"
echo "  - Schedule: */1 * * * *"
echo "  - Start command: ./railway/run-cron.sh"
echo ""
echo "Shared Variables (app, worker, cron):"
cat <<'ENV'
APP_ENV=production
APP_DEBUG=false
APP_KEY=<run: php artisan key:generate --show locally>
APP_URL=https://<your-app>.up.railway.app
DB_CONNECTION=mysql
DB_HOST=${{MySQL.MYSQLHOST}}
DB_PORT=${{MySQL.MYSQLPORT}}
DB_DATABASE=${{MySQL.MYSQLDATABASE}}
DB_USERNAME=${{MySQL.MYSQLUSER}}
DB_PASSWORD=${{MySQL.MYSQLPASSWORD}}
REDIS_HOST=${{Redis.REDISHOST}}
REDIS_PORT=${{Redis.REDISPORT}}
REDIS_PASSWORD=${{Redis.REDIS_PASSWORD}}
QUEUE_CONNECTION=redis
CACHE_STORE=redis
SESSION_DRIVER=redis
ENV

echo ""
echo "After variables are set, trigger deploy from dashboard or: $RAILWAY up"
