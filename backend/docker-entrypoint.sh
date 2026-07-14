#!/bin/sh
set -e

cd /var/www/html || exit 1

if [ -f /var/www/html/artisan ]; then
  php artisan config:clear >/dev/null 2>&1 || true

  for attempt in $(seq 1 30); do
    if php artisan migrate --force; then
      break
    fi

    echo "Migration attempt $attempt failed; retrying in 5 seconds..." >&2
    sleep 5
  done
fi

exec "$@"
