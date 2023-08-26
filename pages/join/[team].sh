# headers

TEAM="${PATH_VARS[team]}"

if [[ "$TEAM" != "red" ]] && [[ "$TEAM" != "yellow" ]]; then
  end_headers
  return $(status_code 404)
fi

if [[ -z "${SESSION[id]}" ]]; then
  end_headers
  return $(status_code 401)
fi

COLOR=$(grep "^${SESSION[id]}"$'\t' data/colors | cut -f2)
if [[ ! -z "$COLOR" ]]; then
  end_headers
  return $(status_code 401)
fi

printf "%s\t%s\n" ${SESSION[id]} $TEAM >> data/colors

header HX-Redirect /team/$TEAM
end_headers
end_headers
