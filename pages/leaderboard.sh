LEADERBOARD=$(head -n 10 data/leaderboard | awk '{ print "<div>"$0"</div>" }')

htmx_page << EOF
  <div class="flex flex-col p-8">
    <h2 class="font-semibold text-2xl">LEADERBOARD</h2>
    <div hx-sse="swap:leaderboard" hx-swap="afterbegin">
        ${LEADERBOARD}
    </div>
  </div>
EOF