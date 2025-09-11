#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# defaults
text=""
tooltip='All good'
class='good'

# Check if alhp.utils command exists, if not consider it as down
if ! command -v alhp.utils &> /dev/null; then
    tooltip="Service unavailable"
    text=""
    class="down"
else
    ALHP_OUTPUT=$(alhp.utils -j)
    mirror_stale=$(jq -r '.mirror_out_of_date' <<<"$ALHP_OUTPUT")

    total=$(jq -r '.total' <<<"$ALHP_OUTPUT")
    mirror_stale=$(jq -r '.mirror_out_of_date' <<<"$ALHP_OUTPUT")

    # safe array even if packages is null
    readarray -t packages < <(
        jq -r '.packages // [] | .[]' <<<"$ALHP_OUTPUT"
        )

    # 1) Mirror stale? highest priority
    if [[ "$mirror_stale" == "true" ]]; then
        class="stale"
        tooltip="Mirror is out of date"
    # 2) Any pending PKGBUILDs?
    elif (( total > 0 )); then
        class="bad"
        text="$total"
        tooltip=$(printf "%s\n" "${packages[@]}")
    fi
fi

case "$class" in
    good)  icon=" ";;
    stale) icon="󰏖 ";;
    bad)   icon="󰏗 ";;
    down)  icon="x ";;
esac

# Emit compact JSON for Statusbar
jq -nc \
    --arg text    "<span color=\"#4F84CC\">$icon</span>  <span color=\"#CAD3E8\">$text</span>" \
    --arg class   "$class" \
    --arg tooltip "$tooltip" \
    '{text: $text, class: $class, tooltip: $tooltip}'

