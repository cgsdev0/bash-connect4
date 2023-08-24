if [[ "$REQUEST_METHOD" != "POST" ]]; then
  # only allow POST to this endpoint
  return $(status_code 405)
fi

source config.sh

reset_board

export UPDATE=true
BOARD_YELLOW=$(component '/board/yellow' | tr -d '\n')
BOARD_RED=$(component '/board/red' | tr -d '\n')
event update "$BOARD_YELLOW" | publish yellow
event update "$BOARD_RED" | publish red
