PROJECT_NAME=connect4
TAILWIND=on

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
echo "50" > data/eval
rm -f data/winlock
}

export -f reset_board

if [[ ! -f data/board ]] \
  || [[ ! -f data/turn ]] \
  || [[ ! -f data/leaderboard ]] \
  || [[ ! -f data/eval ]]; then
    touch data/eval
    touch data/board
    touch data/turn
    touch data/leaderboard
    reset_board
fi

declare -A TEAM_LETTER
TEAM_LETTER[red]=R
TEAM_LETTER[yellow]=Y
