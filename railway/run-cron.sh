#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

exec php artisan schedule:run --verbose --no-interaction
