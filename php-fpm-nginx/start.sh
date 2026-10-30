#!/bin/bash
set -eu

. /expand_secrets.sh

expand_secrets

# Run a one-off command (eg `php artisan migrate`) instead of the web stack
if [ $# -gt 0 ]; then
  exec "$@"
fi

php-fpm -F &
fpm_pid=$!

nginx -g 'daemon off;' &
nginx_pid=$!

stopping=0

# QUIT is the graceful stop signal for both php-fpm and nginx
stop() {
  kill -QUIT "$fpm_pid" "$nginx_pid" 2>/dev/null || true
}
trap 'stopping=1; stop' TERM INT QUIT

# Exit as soon as either process exits, so the container doesn't keep
# running half-broken. A trapped signal also interrupts this wait.
set +e
wait -n "$fpm_pid" "$nginx_pid"
status=$?
stop
wait

if [ "$stopping" = 1 ]; then
  exit 0
fi

# A process died on its own: always report failure so restart policies kick in
echo "php-fpm or nginx exited unexpectedly (status $status)" >&2
exit $(( status == 0 ? 1 : status ))
