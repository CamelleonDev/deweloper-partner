#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

echo "Starting Laravel scheduler loop..."
while true; do
  echo "Running the scheduler..."
  php artisan schedule:run --verbose --no-interaction
  sleep 60
done
