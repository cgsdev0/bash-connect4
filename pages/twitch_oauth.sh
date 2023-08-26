# headers
source .secrets

HOST=${HTTP_HEADERS["host"]}
PROTOCOL="https://"
if [[ "$HOST" =~ "localhost"* ]]; then
  PROTOCOL="http://"
fi

AUTHORIZATION_CODE=${QUERY_PARAMS["code"]}

TWITCH_RESPONSE=$(curl -Ss -X POST \
  "https://id.twitch.tv/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${TWITCH_CLIENT_ID}&client_secret=${TWITCH_CLIENT_SECRET}&code=${AUTHORIZATION_CODE}&grant_type=authorization_code&redirect_uri=${PROTOCOL}${HOST}/twitch_oauth")

ACCESS_TOKEN=$(echo "$TWITCH_RESPONSE" | jq -r '.access_token')
RESPONSE="<pre>${TWITCH_RESPONSE}</pre>"

if [[ -z "$ACCESS_TOKEN" ]] || [[ "$ACCESS_TOKEN" == "null" ]]; then
  end_headers
  htmx_page <<-EOF
  <div class="container">
    <h1>Error</h1>
    ${RESPONSE}
    <p>Something went wrong signing in :(</p>
    <p><a href="/">Back to Home</a></p>
  </div>
EOF
  return $(status_code 400)
fi

TWITCH_RESPONSE=$(curl -Ss -X GET 'https://api.twitch.tv/helix/users' \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Client-Id: $TWITCH_CLIENT_ID")

SESSION[id]="twitch:$(echo $TWITCH_RESPONSE | jq -r '.data[0].id')"
SESSION[pic]="$(echo $TWITCH_RESPONSE | jq -r '.data[0].profile_image_url')"
SESSION[username]="$(echo $TWITCH_RESPONSE | jq -r '.data[0].login')"

save_session

header Location /
end_headers
end_headers

return $(status_code 302)
