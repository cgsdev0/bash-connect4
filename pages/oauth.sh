# headers
source .secrets


AUTHORIZATION_CODE=${QUERY_PARAMS["code"]}

BASIC=$(printf "%s:%s" $TWITTER_CLIENT_ID $TWITTER_CLIENT_SECRET | base64 | tr -d '\n')

TWITTER_RESPONSE=$(curl -Ss -X POST \
  "https://api.twitter.com/2/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "User-Agent: definitelynotbash" \
  -H "Authorization: Basic $BASIC" \
  -d "code=${AUTHORIZATION_CODE}&grant_type=authorization_code&redirect_uri=${PROTOCOL}${HOST}/oauth&code_verifier=challenge")


ACCESS_TOKEN=$(echo "$TWITTER_RESPONSE" | jq -r '.access_token')
RESPONSE="<pre>${TWITTER_RESPONSE}</pre>"

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

TWITTER_RESPONSE=$(curl -Ss -X GET 'https://api.twitter.com/2/users/me?user.fields=profile_image_url' \
  -H "Authorization: Bearer ${ACCESS_TOKEN}")

SESSION[pic]="$(echo $TWITTER_RESPONSE | jq -r '.data.profile_image_url')"
SESSION[username]="$(echo $TWITTER_RESPONSE | jq -r '.data.username')"
SESSION[pic]=${SESSION[pic]/_normal/}
SESSION[id]="$(echo $TWITTER_RESPONSE | jq -r '.data.id')"

save_session

header Location /
end_headers
end_headers

return $(status_code 302)
