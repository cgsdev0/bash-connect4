# headers
source config.sh
source .secrets

HOST=${HTTP_HEADERS["host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

render_page() {
  end_headers
  (echo '<div class="bg-slate-100 dark:bg-slate-950 dark:text-white grid place-content-center h-screen">
  <div class="flex flex-col gap-8">'; \
  cat; \echo "</div></div>"\
  ) | htmx_page
}

if [[ -z "${SESSION[id]}" ]]; then
render_page <<-EOF
  <h1>${PROJECT_NAME}</h1>
  <a class="btn twitter" href="https://twitter.com/i/oauth2/authorize?response_type=code&client_id=${TWITTER_CLIENT_ID}&redirect_uri=${PROTOCOL}${HOST}/oauth&state=state&code_challenge=challenge&code_challenge_method=plain&scope=users.read%20tweet.read">Sign in with Twitter</a>
  <a class="btn twitch" href="https://id.twitch.tv/oauth2/authorize?client_id=${TWITCH_CLIENT_ID}&response_type=code&force_verify=true&redirect_uri=${PROTOCOL}${HOST}/twitch_oauth">Sign in with Twitch</a>
EOF
else
  COLOR=$(grep "^${SESSION[id]}"$'\t' data/colors | cut -f2)
  if [[ -z "$COLOR" ]]; then
    render_page <<-EOF
      <h1>${PROJECT_NAME}</h1>
      <button class="btn btn-red" hx-post="/join/red">Join red team</button>
      <button class="btn btn-yellow" hx-post="/join/yellow">Join yellow team</button>
EOF
  else
    render_page <<-EOF
      <div hx-ext="sse" sse-connect="/sse/$COLOR">
      <div class="flex">
          $(component "/board/$COLOR")
      </div>
      $(component "/leaderboard")
EOF
  fi
fi
