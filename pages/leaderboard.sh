
htmx_page <<-EOF
  <div class="flex flex-col p-8">
    <h2 class="font-semibold text-2xl">MATCH HISTORY</h2>
    <div sse-swap="leaderboard" hx-swap="afterbegin">
      $(tac data/leaderboard | head -n 10 | awk '{ print "<div>"$0"</div>" }')
    </div>
  </div>
EOF
