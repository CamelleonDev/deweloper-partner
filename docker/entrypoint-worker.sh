#!/usr/bin/env bash
set -euo pipefail

cd /var/www/html

exec php artisan queue:work redis --sleep=3 --tries=3 --max-time=3600
