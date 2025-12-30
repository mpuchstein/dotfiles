#!/usr/bin/env bash
set -euo pipefail

cycle_seconds=3

# Critical thresholds (deg C) to match module semantics
cpu_warn=80
cpu_crit=85
gpu_warn=100
gpu_crit=110
nvme_warn=75
nvme_crit=85

resolve_hwmon_file() {
  local base="$1" file="$2" sub
  if [[ -r "$base/$file" ]]; then
    printf '%s' "$base/$file"
    return 0
  fi
  if [[ -d "$base" ]]; then
    for sub in "$base"/hwmon*; do
      if [[ -r "$sub/$file" ]]; then
        printf '%s' "$sub/$file"
        return 0
      fi
    done
  fi
  return 1
}

resolve_hwmon_by_name() {
  local target="$1" file="$2" h
  [[ -n "$target" ]] || return 1
  for h in /sys/class/hwmon/hwmon*; do
    [[ -r "$h/name" ]] || continue
    if [[ "$(cat "$h/name")" == "$target" && -r "$h/$file" ]]; then
      printf '%s' "$h/$file"
      return 0
    fi
  done
  return 1
}

read_temp() {
  local base="$1" file="$2" fallback="$3" raw path
  if path=$(resolve_hwmon_file "$base" "$file"); then
    :
  elif path=$(resolve_hwmon_by_name "$fallback" "$file"); then
    :
  else
    return 1
  fi
  raw=$(<"$path")
  if [[ "$raw" =~ ^[0-9]+$ ]]; then
    printf '%s' "$((raw / 1000))"
    return 0
  fi
  return 1
}

cpu_path="/sys/devices/pci0000:00/0000:00:18.3/hwmon"
gpu_path="/sys/devices/pci0000:00/0000:00:01.1/0000:10:00.0/0000:11:00.0/0000:12:00.0/hwmon"
nvme_path="/sys/devices/pci0000:00/0000:00:02.2/0000:23:00.0/nvme/nvme0/hwmon"

labels=()
keys=()
icons=()
values=()
warn=()
crit=()

if temp=$(read_temp "$cpu_path" "temp1_input" "k10temp"); then
  labels+=("CPU")
  keys+=("cpu")
  icons+=("")
  values+=("$temp")
  warn+=("$cpu_warn")
  crit+=("$cpu_crit")
fi

if temp=$(read_temp "$gpu_path" "temp2_input" "amdgpu"); then
  labels+=("GPU")
  keys+=("gpu_hotspot")
  icons+=("")
  values+=("$temp")
  warn+=("$gpu_warn")
  crit+=("$gpu_crit")
fi

if temp=$(read_temp "$nvme_path" "temp1_input" "nvme"); then
  labels+=("NVMe")
  keys+=("nvme")
  icons+=("")
  values+=("$temp")
  warn+=("$nvme_warn")
  crit+=("$nvme_crit")
fi

count=${#values[@]}
if (( count == 0 )); then
  jq -nc --arg text " --" --arg tooltip "No temp sensors found" \
    '{text:$text, tooltip:$tooltip, class:["down"]}'
  exit 0
fi

idx=$(( ($(date +%s) / cycle_seconds) % count ))
val=${values[idx]}
key=${keys[idx]}
warn_threshold=${warn[idx]}
critical_threshold=${crit[idx]}

is_warning=false
is_critical=false
if (( val >= critical_threshold )); then
  is_critical=true
elif (( val >= warn_threshold )); then
  is_warning=true
fi

text="${icons[idx]} ${val}°C"

tooltip=""
for i in "${!values[@]}"; do
  if [[ -n "$tooltip" ]]; then
    tooltip+='\n'
  fi
  tooltip+="${labels[i]}: ${values[i]}°C"
done

jq -nc \
  --arg text "$text" \
  --arg tooltip "$tooltip" \
  --arg key "$key" \
  --argjson is_warning "$is_warning" \
  --argjson is_critical "$is_critical" \
  '{text:$text, tooltip:$tooltip, class: ([$key] + (if $is_critical then ["critical"] elif $is_warning then ["warning"] else [] end)) }'
