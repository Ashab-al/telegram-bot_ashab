#!/bin/bash
set -e

rm -f /chatbottg/tmp/pids/server.pid

exec "$@"