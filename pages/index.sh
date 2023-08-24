
source config.sh

htmx_page << EOF
  <h1 class="text-blue-500 text-4xl mt-3 mb-3">${PROJECT_NAME}</h1>
  <a href="/team/red">Join Red</a>
  <a href="/team/yellow">Join Yellow</a>
  $(component '/count')
EOF
