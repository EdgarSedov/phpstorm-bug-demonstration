#!/bin/sh

php artisan optimize

trap 'kill -TERM $PID' TERM INT
exec "$@" &
PID=$!
wait $PID
wait $PID
