# headers
source config.sh
source .secrets

HOST=${HTTP_HEADERS["host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

if [[ -z "${SESSION[id]}" ]]; then
end_headers
htmx_page <<-EOF
  <h1 class="text-blue-500 text-4xl mt-3 mb-3">${PROJECT_NAME}</h1>
  <a href="https://twitter.com/i/oauth2/authorize?response_type=code&client_id=${TWITTER_CLIENT_ID}&redirect_uri=${PROTOCOL}${HOST}/oauth&state=state&code_challenge=challenge&code_challenge_method=plain&scope=users.read%20tweet.read">Sign in with Twitter</a>
EOF
else
  COLOR=$(grep "^${SESSION[id]}"$'\t' data/colors | cut -f2)
  if [[ -z "$COLOR" ]]; then
    end_headers
    htmx_page <<-EOF
      <h1 class="text-blue-500 text-4xl mt-3 mb-3">${PROJECT_NAME}</h1>
      <button hx-post="/join/red">Join red team</button>
      <button hx-post="/join/yellow">Join yellow team</button>
EOF
  else
    end_headers
    htmx_page <<-EOF
      <div hx-ext="sse" sse-connect="/sse/$COLOR">
      <div class="flex">
          $(component "/board/$COLOR")
      </div>
      $(component "/leaderboard")
EOF
  fi
fi
