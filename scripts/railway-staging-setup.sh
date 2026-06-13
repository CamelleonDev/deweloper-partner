#!/usr/bin/env bash
# Run after: railway login && git remote add origin <url> && git push -u origin main
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

railway_cmd() {
  if [[ -n "${RAILWAY_CMD:-}" ]]; then
    # shellcheck disable=SC2086
    $RAILWAY_CMD "$@"
  elif command -v railway >/dev/null 2>&1; then
    railway "$@"
  else
    echo "ERROR: Railway CLI not found. Install once:" >&2
    echo "  npm install -g @railway/cli" >&2
    echo "Then: railway login --browserless" >&2
    exit 1
  fi
}

echo "==> Checking Railway auth"
if ! railway_cmd whoami; then
  echo ""
  echo "Not logged in. Run in your terminal (not npx — it hangs on reinstall):"
  echo "  npm install -g @railway/cli"
  echo "  railway login --browserless"
  echo "  # open https://railway.com/activate and paste the code"
  exit 1
fi

echo "==> Linking Railway project (creates if needed)"
if [[ ! -f .railway/project.json ]]; then
  railway_cmd init --name deweloper-partner-staging
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
echo "  - Same repo; long-running service (not Cron Schedule — min 5 min on Railway)"
echo "  - Start command: chmod +x ./railway/run-cron.sh && ./railway/run-cron.sh"
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
echo "After variables are set, trigger deploy from dashboard or: railway up"
