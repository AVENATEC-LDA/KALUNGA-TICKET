#!/bin/sh
set -e

if [ -f /var/www/html/artisan ]; then
  php artisan config:clear >/dev/null 2>&1 || true
  php artisan migrate --force
fi

exec "$@"
