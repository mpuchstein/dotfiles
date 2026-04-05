#!/usr/bin/env bash
# AMD GPU stats for Waybar (RDNA 4 / amdgpu)

set -o pipefail

read_numeric_file() {
    local path="$1"
    local value
    [[ -r "$path" ]] || return 1
    value=$(<"$path")
    [[ "$value" =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "$value"
}

# Find AMD GPU hwmon
GPU_HWMON=""
for hwmon in /sys/class/hwmon/hwmon*; do
    if [[ -f "$hwmon/name" ]] && grep -q "amdgpu" "$hwmon/name" 2>/dev/null; then
        GPU_HWMON="$hwmon"
        break
    fi
done

if [[ -z "$GPU_HWMON" ]]; then
    echo '{"text":"󰢮","class":"disconnected","tooltip":"AMD GPU not found"}'
    exit 0
fi

GPU_DEVICE=$(readlink -f "$GPU_HWMON/device" 2>/dev/null || true)

# Read GPU stats
temp_raw=0
for temp_sensor in temp1_input temp2_input temp3_input; do
    if temp_candidate=$(read_numeric_file "$GPU_HWMON/$temp_sensor"); then
        temp_raw="$temp_candidate"
        break
    fi
done
temp=$((temp_raw / 1000))

# GPU usage from /sys/class/drm
gpu_busy=0
if [[ -n "$GPU_DEVICE" ]] && gpu_busy_candidate=$(read_numeric_file "$GPU_DEVICE/gpu_busy_percent"); then
    gpu_busy="$gpu_busy_candidate"
else
    for card in /sys/class/drm/card*/device/gpu_busy_percent; do
        if gpu_busy_candidate=$(read_numeric_file "$card"); then
            gpu_busy="$gpu_busy_candidate"
            break
        fi
    done
fi

# VRAM usage
vram_used=0
vram_total=0
if [[ -n "$GPU_DEVICE" ]] && [[ -r "$GPU_DEVICE/mem_info_vram_used" ]]; then
    vram_used_raw=$(read_numeric_file "$GPU_DEVICE/mem_info_vram_used" || echo 0)
    vram_total_raw=$(read_numeric_file "$GPU_DEVICE/mem_info_vram_total" || echo 0)
    vram_used=$((vram_used_raw / 1024 / 1024))
    vram_total=$((vram_total_raw / 1024 / 1024))
else
    for card in /sys/class/drm/card*/device; do
        if [[ -r "$card/mem_info_vram_used" ]]; then
            vram_used_raw=$(read_numeric_file "$card/mem_info_vram_used" || echo 0)
            vram_total_raw=$(read_numeric_file "$card/mem_info_vram_total" || echo 0)
            vram_used=$((vram_used_raw / 1024 / 1024))
            vram_total=$((vram_total_raw / 1024 / 1024))
            break
        fi
    done
fi

# Power usage (watts)
power_raw=0
for power_sensor in power1_average power1_input; do
    if power_candidate=$(read_numeric_file "$GPU_HWMON/$power_sensor"); then
        power_raw="$power_candidate"
        break
    fi
done
power=$((power_raw / 1000000))

# Determine class based on temperature
if [[ $temp -ge 90 ]]; then
    class="critical"
elif [[ $temp -ge 75 ]]; then
    class="warning"
elif [[ $gpu_busy -ge 90 ]]; then
    class="high"
else
    class="normal"
fi

# Format text
text="󰢮 ${temp}°C"

# Build tooltip with actual newlines
NL=$'\n'
tooltip="AMD GPU${NL}Usage: ${gpu_busy}%${NL}Temp: ${temp}°C${NL}Power: ${power}W"
if [[ $vram_total -gt 0 ]]; then
    vram_pct=$((vram_used * 100 / vram_total))
    tooltip="${tooltip}${NL}VRAM: ${vram_used}/${vram_total} MB (${vram_pct}%)"
fi

jq -nc \
    --arg text "$text" \
    --arg class "$class" \
    --arg tooltip "$tooltip" \
    '{text: $text, class: $class, tooltip: $tooltip}'
