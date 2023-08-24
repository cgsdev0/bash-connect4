LEADERBOARD=$(tac data/leaderboard | head -n 10 | awk '{ print "<div>"$0"</div>" }')

htmx_page <<-EOF
  <div class="flex flex-col p-8">
    <h2 class="font-semibold text-2xl">LEADERBOARD</h2>
    <div sse-swap="leaderboard" hx-swap="afterbegin">
        ${LEADERBOARD}
    </div>
  </div>
EOF
