# sse

TEAM="${PATH_VARS[team]}"

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  return $(status_code 404)
fi


topic() {
    echo "$TEAM"
}

on_open() {
  touch pubsub/conns-$TEAM
  printf "%s\t%s\t%s\n" "${CONN_ID}" "${SESSION[pic]}" "${SESSION[username]}" >> pubsub/conns-$TEAM
  CONNS="$(component /conns | tr -d '\n')"
  event conns "$CONNS" | publish_all
}

on_close() {
  touch pubsub/conns-$TEAM
  sed -i "/^${CONN_ID}\t/d" pubsub/conns-$TEAM
  CONNS="$(component /conns | tr -d '\n')"
  event conns "$CONNS" | publish_all
}
