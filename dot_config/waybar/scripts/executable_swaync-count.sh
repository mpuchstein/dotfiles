#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

count_raw=$(swaync-client -c 2>/dev/null || echo "")
if [[ "$count_raw" =~ ^[0-9]+$ ]]; then
  count=$count_raw
else
  count=0
fi

class="clear"
text=""
tooltip="No notifications"

if (( count > 0 )); then
  class="unread"
  text=" $count"
  tooltip="Unread: $count"
fi

jq -nc \
  --arg text "$text" \
  --arg class "$class" \
  --arg tooltip "$tooltip" \
  '{text:$text, class:$class, tooltip:$tooltip}'
