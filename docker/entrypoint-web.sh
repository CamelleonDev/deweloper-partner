#!/usr/bin/env bash
set -euo pipefail

export PORT="${PORT:-8080}"

envsubst '${PORT}' < /etc/nginx/templates/railway.conf.template > /etc/nginx/sites-available/default

php-fpm -D
exec nginx -g 'daemon off;'
