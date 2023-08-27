
function players() {
      tail -n 20 pubsub/conns-$1 | sort -k2 -u | awk '{ print "<img src=\""$2"\" alt=\""$3"\" />" }'
}

RED_TEAM="$(players red)"
YELLOW_TEAM="$(players yellow)"

RED_SIZE=$(echo "$RED_TEAM" | wc -l)
RED_SIZE=$(( RED_SIZE / 2 ))
YELLOW_SIZE=$(echo "$YELLOW_TEAM" | wc -l)
YELLOW_SIZE=$(( YELLOW_SIZE / 2 ))


# -space-x-0
# -space-x-1
# -space-x-2
# -space-x-3
# -space-x-4
# -space-x-5
# -space-x-6
# -space-x-7
# -space-x-8
# -space-x-9
# -space-x-10

if [[ -z "$YELLOW_TEAM" ]]; then
  YELLOW_TEAM="<p>No players connected.</p>"
fi

if [[ -z "$RED_TEAM" ]]; then
  RED_TEAM="<p>No players connected.</p>"
fi
htmx_page <<-EOF
  <div id="conns">
    <div class="-space-x-${RED_SIZE} players">
      <h2 class="red">Red</h2>
      ${RED_TEAM}
    </div>
    <div class="-space-x-${YELLOW_SIZE} players">
    <h2 class="yellow">Yellow</h2>
      ${YELLOW_TEAM}
    </div>
  </div>
EOF
