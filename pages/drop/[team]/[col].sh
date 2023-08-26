if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

if [[ "$REQUEST_METHOD" != "POST" ]]; then
  # only allow POST to this endpoint
  return $(status_code 405)
fi

if [[ -f data/winlock ]]; then
  return $(status_code 423)
fi
source config.sh

TEAM="${PATH_VARS[team]}"

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  return $(status_code 404)
fi

CURRENT_TURN="$(cat data/turn)"
if [[ "$TEAM" != "$CURRENT_TURN" ]]; then
  return $(status_code 425)
fi

LETTER="${TEAM_LETTER[$TEAM]}"
LOWER_LETTER="${LETTER,,}"
LETTER_X4="$LETTER$LETTER$LETTER$LETTER"

function write() {
    local ROW
    local COL
    ROW=$1
    (( ROW++ ))
    COL=$2
    (( COL-- ))
    sed -i -e 's/\(.*\)/\U\1/' data/board
    sed -i -E "$ROW,${ROW}s@(.{$COL}).(.*)@\1${LOWER_LETTER}\2@" data/board
}

function find_row() {
    local COL
    local INDEX
    COL=$1
    (( COL-- ))
    INDEX=0
    while IFS= read -r line; do
        if [[ "${line:$COL:1}" != "0" ]]; then
            echo $(( INDEX - 1 ))
            return
        fi
        (( INDEX++ ))
    done < data/board
    echo $(( $INDEX - 1 ))
}

check_connect_4_horizontal_vertical() {
  FILE=$1
  # Check for horizontal connect 4
  grep -q -i "$LETTER_X4" data/board && return 0

  # Check for vertical connect 4
  for ((i=1; i<=12; i++)); do
    col=$(awk -F '' -v i="$i" '{print $i}' $FILE | tr -d '\n')
    [[ "${col^^}" == *"$LETTER_X4"* ]] && return 0
  done
  return 1
}

# TODO: optimize this
function check_connect_5head() {
    local line
    local INDEX
    WIDTH=0
    while read -r line; do
        EMPTY="$(printf '%*s' $WIDTH)"
        echo "$EMPTY$line"
        (( WIDTH++ ))
    done < data/board > data/board2
    WIDTH=5
    while read -r line; do
        EMPTY="$(printf '%*s' $WIDTH)"
        echo "$EMPTY$line"
        (( WIDTH-- ))
    done < data/board > data/board3
    check_connect_4_horizontal_vertical data/board \
    || check_connect_4_horizontal_vertical data/board2 \
    || check_connect_4_horizontal_vertical data/board3
}

function stalemate() {
  if ! grep -q 0 data/board; then
    return 0
  fi
  return 1
}

ROW=$(find_row ${PATH_VARS[col]})
if [[ $ROW == "-1" ]]; then
    return $(status_code 405)
fi

if [[ "$CURRENT_TURN" == "red" ]]; then
  echo "yellow" > data/turn
else
  echo "red" > data/turn
fi

write $ROW ${PATH_VARS[col]}
COL=${PATH_VARS[col]}
printf ${PATH_VARS[col]} >>data/moves
CELL_ID=$(( ROW * 7 + (COL - 1) ))
debug "$CELL_ID"
printf "%s %s\n" $CELL_ID ${SESSION[pic]} >>data/pics

evaluate() {
  local EVALUATION
  local EVAL
  if [[ "${DEV:-true}" == "true" ]]; then
    EVALUATION=$(./lib/evaluation/target/debug/evaluation < data/moves)
  else
    EVALUATION=$(./lib/evaluation/target/release/evaluation < data/moves)
  fi
  if [[ ! -z "$EVALUATION" ]]; then
    echo "$EVALUATION" > data/eval
    event evaluation "$(evaluation $EVALUATION)" | publish_all
  fi
}


if check_connect_5head; then
  STR="${TEAM_EMOJI[$TEAM]} $(date '+%h %d %H:%M') ${TEAM^} team won!"
  printf "%s\n" "$STR" >> data/leaderboard
  echo "$TEAM" > data/winlock
  if [[ "$TEAM" == "yellow" ]]; then
    event evaluation "$(evaluation 100)" | publish_all
  else
    event evaluation "$(evaluation 0)" | publish_all
  fi
  event leaderboard "<div>$STR</div>" | publish_all
elif stalemate; then
  STR="${TEAM_EMOJI[stalemate]} $(date '+%h %d %H:%M') Stalemate :("
  printf "%s\n" "$STR" >> data/leaderboard
  event evaluation "$(evaluation 50)" | publish_all
  event leaderboard "<div>$STR</div>" | publish_all
  reset_board
else
  # asynchronous evaluation
  evaluate &
fi

export UPDATE=true
BOARD_YELLOW=$(component '/board/yellow' | tr -d '\n')
BOARD_RED=$(component '/board/red' | tr -d '\n')
event update "$BOARD_YELLOW" | publish yellow
event update "$BOARD_RED" | publish red
