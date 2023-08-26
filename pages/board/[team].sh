TEAM="${PATH_VARS[team]}"

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  return $(status_code 404)
fi

BOARD=$(awk '
{
  printf("<tr class=\"select-none\">")
  split($0, chars, "")
  for (i=1; i <= length($0); i++) {
    printf("<td hx-post=\"/drop/'$TEAM'/%d\" class=\"square\"><div class=\"type-%s\">PLACEHOLDER-%s-</div></td>\n", i, chars[i], (NR -1) * 7 + (i - 1))
  }
  printf("</tr>")
}
' data/board)

while read -r CELL_ID PIC; do
  debug "$CELL_ID"
  BOARD=${BOARD/PLACEHOLDER-${CELL_ID}-/<img src="$PIC" />}
done < data/pics
for i in {0..42}; do
  BOARD=${BOARD//PLACEHOLDER-$i-}
done
CURRENT_TEAM="$(cat data/turn)"

# text-red-500
# text-yellow-500
# bg-red-100
# bg-yellow-100

EVALUATION=$(cat data/eval)

if [[ -f data/winlock ]]; then
    WINNER=$(cat data/winlock)
    WINNING_TEAM="bg-$WINNER-100"
    if [[ "$WINNER" == "red" ]]; then
      EVALUATION="0"
    else
      EVALUATION="100"
    fi
fi

if [[ ! -z "$UPDATE" ]]; then
  OOB="hx-swap-oob=true "
fi

turn_text() {
    if [[ -z "$WINNER" ]]; then
      echo '<h1 '"$OOB"' class="h1 font-semibold text-'${CURRENT_TEAM}'-500" id="turn">'${CURRENT_TEAM^}'&apos;s Turn</h1>'
    else
      echo '<h1 '"$OOB"' class="h1 font-semibold text-'${WINNER}'-500" id="turn">'${WINNER^}' Wins!</h1>'
    fi
}

bar() {
  if [[ -z "$EVALUATION" ]]; then
    return
  fi
  cat <<-EOF
  <div id="evaluation" class="rounded overflow-hidden h-full bg-red-500 w-8 mr-6 -ml-2" sse-swap="evaluation">
    <div class="bg-yellow-500 w-full" id="evalbar" style="height: ${EVALUATION}%;"></div>
  </div>
EOF
}

button() {
  [[ -f data/winlock ]] || return
  cat <<-EOF
  <button class="new-game" hx-post="/reset" id="newgame">
      New game
  </button>
EOF
}
if [[ -z "$UPDATE" ]]; then
  htmx_page <<-EOF
    <div id="game-wrapper" class="flex flex-col">
      $(turn_text)
      <div id="board-wrapper" class="flex flex-row">
        $(bar)
        <div sse-swap="update" class="relative">
          <table id="board" class="select-none $WINNING_TEAM">
              ${BOARD}
          </table>
          $(button)
        </div>
      </div>
    </div>
EOF
else
  htmx_page <<-EOF
    $(turn_text)
    $(button)
    <table id="board" class="select-none $WINNING_TEAM">
        ${BOARD}
    </table>
EOF
fi
