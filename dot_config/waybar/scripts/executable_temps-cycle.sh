#!/usr/bin/env bash
set -euo pipefail

cycle_seconds=3

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
icons=()
values=()

if temp=$(read_temp "$cpu_path" "temp1_input" "k10temp"); then
  labels+=("CPU")
  icons+=("")
  values+=("$temp")
fi

if temp=$(read_temp "$gpu_path" "temp2_input" "amdgpu"); then
  labels+=("GPU")
  icons+=("")
  values+=("$temp")
fi

if temp=$(read_temp "$nvme_path" "temp1_input" "nvme"); then
  labels+=("NVMe")
  icons+=("")
  values+=("$temp")
fi

count=${#values[@]}
if (( count == 0 )); then
  printf '{"text":" --","tooltip":"No temp sensors found"}\n'
  exit 0
fi

idx=$(( ($(date +%s) / cycle_seconds) % count ))
text="${icons[idx]} ${values[idx]}°C"

tooltip=""
for i in "${!values[@]}"; do
  if [[ -n "$tooltip" ]]; then
    tooltip+='\n'
  fi
  tooltip+="${labels[i]}: ${values[i]}°C"
done

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
