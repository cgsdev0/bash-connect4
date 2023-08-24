TEAM="${PATH_VARS[team]}"

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  return $(status_code 404)
fi

BOARD=$(awk '
{ 
  printf("<tr class=\"select-none\">")
  split($0, chars, "")
  for (i=1; i <= length($0); i++) {
    printf("<td hx-post=\"/drop/'$TEAM'/%d\" class=\"square type-%s\"></td>\n", i, chars[i])
  }
  printf("</tr>")
}
' data/board)

CURRENT_TEAM="$(cat data/turn)"

# text-red-500
# text-yellow-500
# bg-red-100
# bg-yellow-100

TURN_TEXT='<p class="mt-12 font-semibold text-2xl text-'${CURRENT_TEAM}'-500" id="turn" hx-swap-oob="true">'${CURRENT_TEAM^}'&apos;s Turn</p>'
if [[ -f data/winlock ]]; then
    WINNER=$(cat data/winlock)
    WINNING_TEAM="bg-$WINNER-100"
    TURN_TEXT='<p class="mt-12 font-semibold text-2xl text-'${WINNER}'-500" id="turn" hx-swap-oob="true">'${WINNER^}' Wins!</p>'
fi

EVALUATION=$(cat data/moves | ./lib/evaluation/target/debug/evaluation)

htmx_page << EOF
  $TURN_TEXT
  <table id="board" class="select-none $WINNING_TEAM" hx-swap="outerHTML" hx-sse="swap:update">
      ${BOARD}
  </table>
  <div id="evaluation" hx-target="this" hx-swap-oob="true" class="w-full bg-red-500 h-12">
      <div class="bg-yellow-500 h-full" style="width: ${EVALUATION}%"></div>
  </div>
EOF