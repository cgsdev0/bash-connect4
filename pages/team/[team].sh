
TEAM=${PATH_VARS[team]}

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  return $(status_code 404)
fi


htmx_page <<-EOF
    <div hx-ext="sse" sse-connect="/sse/$TEAM">
    <div class="flex">
        $(component "/board/$TEAM")
    </div>

        $(component "/leaderboard")
    </div>
        <button class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-5 px-4 mt-8 rounded" hx-post="/reset" hx-swap="none">
            New game
        </button>
    </div>
EOF
