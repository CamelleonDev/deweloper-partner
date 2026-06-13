#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

# Railway cron = long-running service (see docs.railway.com/guides/laravel).
# Native Cron Schedule min interval is 5 min; loop gives Laravel every-minute ticks.
while true; do
  echo "Running the scheduler..."
  php artisan schedule:run --verbose --no-interaction
  sleep 60
done
