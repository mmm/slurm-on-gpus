#!/bin/sh


set -eu

# first arg is `-e` or `--some-option` (docker run ghpc -e '42')
# ... or there are no args
if [ "$#" -eq 0 ] \
  || [ "${1#-}" != "$1" ] \
  || [ "${1#completion}" != "$1" ] \
  || [ "${1#create}" != "$1" ] \
  || [ "${1#expand}" != "$1" ] \
  || [ "${1#help}" != "$1" ]; then
	exec ghpc "$@"
fi

exec "$@"
