#!/usr/bin/env bash

cd "${0%/*}"

[[ -f 'config.sh' ]] && source config.sh

if [[ "${DEV:-true}" == "true" ]]; then
  if [[ ! -z "$TAILWIND" ]]; then
    npx tailwindcss -i ./static/style.css -o ./static/tailwind.css --watch=always 2>&1 |
      sed '/^[[:space:]]*$/d;s/^/[tailwind] /' &
    TW_PID=$!
  fi
  cargo watch -x build -C lib/evaluation | sed 's/^/[evaluation] /' &
  RS_PID=$!
fi

# remove any old subscriptions; they are no longer valid
rm -rf pubsub

mkdir -p pubsub
mkdir -p data
mkdir -p uploads

PORT=${PORT:-3000}
echo -n "Listening on port "
tcpserver -1 -o -l 0 -H -R -c 1000 0 $PORT ./core.sh

if [[ ! -z "$TW_PID" ]]; then
  kill "$TW_PID"
fi
if [[ ! -z "$RS_PID" ]]; then
  kill "$RS_PID"
fi
