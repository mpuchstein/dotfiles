#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

text=""
tooltip="All good"
class="good"

if ! command -v alhp.utils >/dev/null 2>&1; then
  class="down"
  tooltip="Service unavailable"
else
  if ! ALHP_OUTPUT=$(alhp.utils -j 2>/dev/null); then
    class="down"
    tooltip="Service error"
  else
    total=$(jq -r '.total // 0' <<<"$ALHP_OUTPUT" 2>/dev/null || echo 0)
    mirror_stale=$(jq -r '.mirror_out_of_date // false' <<<"$ALHP_OUTPUT" 2>/dev/null || echo false)

    readarray -t packages < <(jq -r '.packages // [] | .[]' <<<"$ALHP_OUTPUT" 2>/dev/null || true)

    if [[ "$mirror_stale" == "true" ]]; then
      class="stale"
      tooltip="Mirror is out of date"
    elif (( total > 0 )); then
      class="bad"
      text="$total"
      if (( ${#packages[@]} > 0 )); then
        tooltip=$(printf "%s\n" "${packages[@]}")
      else
        tooltip="Pending: $total"
      fi
    fi
  fi
fi

case "$class" in
  good)  icon="" ;;
  stale) icon="󰏖" ;;
  bad)   icon="󰏗" ;;
  down)  icon="󰅖" ;;
esac

out="$icon"
[[ -n "$text" ]] && out+=" $text"

jq -nc \
  --arg text "$out" \
  --arg class "$class" \
  --arg tooltip "$tooltip" \
  '{text:$text, class:$class, tooltip:$tooltip}'
