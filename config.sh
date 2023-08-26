PROJECT_NAME=connect4
TAILWIND=on
ENABLE_SESSIONS=true

reset_board() {
cat <<-EOF > data/board
0000000
0000000
0000000
0000000
0000000
0000000
EOF
echo "red" > data/turn
printf "" > data/moves
printf "" > data/pics
echo "50" > data/eval
rm -f data/winlock
}

evaluation() {
  echo "<div class='bg-yellow-500 w-full' id='evalbar' style='height: $1%;'></div>"
}

publish_all() {
  tee >(publish red) >(publish yellow) > /dev/null
}

export -f publish_all
export -f reset_board
export -f evaluation

if [[ ! -f data/board ]] \
  || [[ ! -f data/turn ]] \
  || [[ ! -f data/leaderboard ]] \
  || [[ ! -f data/colors ]] \
  || [[ ! -f data/pics ]] \
  || [[ ! -f data/eval ]]; then
    touch data/eval
    touch data/board
    touch data/turn
    touch data/leaderboard
    touch data/colors
    touch data/pics
    reset_board
fi

declare -A TEAM_LETTER
TEAM_LETTER[red]=R
TEAM_LETTER[yellow]=Y

declare -A TEAM_EMOJI
TEAM_EMOJI[red]=🔴
TEAM_EMOJI[yellow]=🟡
TEAM_EMOJI[stalemate]=⚫
