# Apex Aeon — Predator Cockpit (Zsh) — v1
# Two-bus design:
#   [precmd radar]  -> after-action + context bursts (event-driven)
#   [promptline]    -> LEFT: identity + territory
#                      RIGHT: intel + vcs + friction (stable)

setopt prompt_subst
setopt no_beep

zmodload zsh/datetime 2>/dev/null

# -----------------------------------------------------------------------------
# 1) PALETTE (Apex Aeon DNA)
# -----------------------------------------------------------------------------
typeset -gA C
C[VOID]="#f5f5f5"
C[WHITE]="#0a0a0a"
C[MUTED]="#737373"
C[RAZOR]="#ff0044"
C[CYAN]="#007a88"
C[GOLD]="#d18f00"
C[OK]="#00b377"
C[PURPLE]="#7a3cff"
C[ALERT]="#ff4d6d"

# -----------------------------------------------------------------------------
# 2) ICONS / GLYPHS (Nerd Font optional)
# -----------------------------------------------------------------------------
typeset -gA I
I[OS]=""
I[SSH]=""
I[ROOT]=""
I[GIT]=""
I[JOBS]=""
I[RADAR]="⌁"
I[RET]="↩"

typeset -gA S
S[PL_L]=""
S[PL_R]=""
S[DOT]="·"

# -----------------------------------------------------------------------------
# 3) CONFIG
# -----------------------------------------------------------------------------
typeset -gA APEX
APEX[SLOW_SOFT_MS]=750
APEX[SLOW_HARD_MS]=2000

APEX[STARTUP_BURST]=1
APEX[SHOW_AAR]=1
APEX[SHOW_CONTEXT_BURST]=1
APEX[SHOW_VCS]=1
APEX[SHOW_INTEL]=1
APEX[SHOW_JOBS]=1
APEX[SHOW_RO]=1
APEX[GIT_AHEAD_BEHIND]=1

# Ops commands (also match wrappers like sudo/doas/command)
APEX[OPS_RE]='^((sudo|doas|command)[[:space:]]+)*((pacman|yay|paru|apt|dnf|brew|systemctl|docker|kubectl|helm|git))([[:space:]]|$)'

# Session-ish commands (spawn a subshell; exit codes are often “not a failure”)
APEX[SESSION_RE]='^((sudo|doas|command)[[:space:]]+)*chezmoi[[:space:]]+cd([[:space:]]|$)'

# -----------------------------------------------------------------------------
# 4) STATE
# -----------------------------------------------------------------------------
typeset -gF apex_cmd_start=0.0
typeset -g  apex_last_cmd=""
typeset -g  apex_has_run_cmd=0

typeset -g  apex_startup_done=0
typeset -g  apex_pwd_changed=1

# Sticky intel
typeset -g  apex_venv_name=""
typeset -g  apex_target_sig=""
typeset -g  apex_mode_sig=""

# Git state
typeset -g  apex_in_git=0
typeset -g  apex_git_branch=""
typeset -g  apex_git_dirty_wt=0
typeset -g  apex_git_dirty_ix=0
typeset -g  apex_git_untracked=0
typeset -g  apex_git_conflict=0
typeset -g  apex_git_op=""
typeset -g  apex_git_up_ok=0
typeset -g  apex_git_ahead=0
typeset -g  apex_git_behind=0
typeset -g  apex_git_stash=0
typeset -g  apex_git_root=""
typeset -g  apex_git_dir=""

# Radar previous snapshots (transition detection)
typeset -g  apex_prev_in_git=-1
typeset -g  apex_prev_git_branch=""
typeset -g  apex_prev_git_op=""
typeset -g  apex_prev_venv_name=""
typeset -g  apex_prev_target_sig=""
typeset -g  apex_prev_proj_sig=""

# -----------------------------------------------------------------------------
# 5) UTILITIES
# -----------------------------------------------------------------------------
apex__short_cmd() {
  local s="$1"
  s="${s//$'
'/ }"
  s="${s#"${s%%[![:space:]]*}"}"   # ltrim
  s="${s%"${s##*[![:space:]]}"}"   # rtrim
  print -r -- "${s[1,90]}"
}

apex__project_sig() {
  local s=""
  [[ -f package.json ]] && s+="node"
  [[ -f pnpm-lock.yaml ]] && s+="+pnpm"
  [[ -f bun.lockb ]] && s+="+bun"
  [[ -f yarn.lock ]] && s+="+yarn"

  [[ -f pyproject.toml || -f requirements.txt ]] && s+="${s:+ }py"
  [[ -f uv.lock ]] && s+="+uv"

  [[ -f Cargo.toml ]] && s+="${s:+ }rust"
  [[ -f go.mod ]] && s+="${s:+ }go"

  [[ -n "$s" ]] && print -r -- "$s"
}

apex__escape_prompt() {
  local s="$1"
  s="${s//\\%/%%}"
  print -r -- "$s"
}

apex__now_float() {
  if [[ -n "${EPOCHREALTIME:-}" ]]; then
    print -r -- "$EPOCHREALTIME"
  elif [[ -n "${EPOCHSECONDS:-}" ]]; then
    print -r -- "${EPOCHSECONDS}.0"
  else
    print -r -- "0.0"
  fi
}

apex__find_git_root() {
  local dir="$PWD"
  local git_root=""
  local git_dir=""

  while [[ -n "$dir" ]]; do
    if [[ -d "$dir/.git" ]]; then
      git_root="$dir"
      git_dir="$dir/.git"
      break
    elif [[ -f "$dir/.git" ]]; then
      local line
      line="$(<"$dir/.git")"
      if [[ "$line" == gitdir:* ]]; then
        git_root="$dir"
        git_dir="${line#gitdir: }"
        [[ "$git_dir" != /* ]] && git_dir="$dir/$git_dir"
        break
      fi
    fi

    [[ "$dir" == "/" ]] && break
    dir="${dir:h}"
  done

  [[ -n "$git_root" ]] && print -r -- "${git_root}|${git_dir}"
}

# -----------------------------------------------------------------------------
# 6) INTEL (sticky; updated each prompt)
# -----------------------------------------------------------------------------
apex_update_intel() {
  # Target (cheap env-based; no kubectl calls)
  if [[ -n "$AWS_PROFILE" ]]; then
    apex_target_sig="aws:${AWS_PROFILE}"
  elif [[ -n "$GOOGLE_CLOUD_PROJECT" ]]; then
    apex_target_sig="gcp:${GOOGLE_CLOUD_PROJECT}"
  elif [[ -n "$KUBE_CONTEXT" ]]; then
    apex_target_sig="kube:${KUBE_CONTEXT}"
  else
    apex_target_sig=""
  fi

  # Mode
  if [[ -n "$IN_NIX_SHELL" ]]; then
    apex_mode_sig="nix"
  elif [[ -n "$DIRENV_DIR" ]]; then
    apex_mode_sig="direnv"
  elif [[ -f /run/.containerenv || -f /.dockerenv ]]; then
    apex_mode_sig="ctr"
  else
    apex_mode_sig=""
  fi

  # Venv
  apex_venv_name=""
  if [[ -n "$VIRTUAL_ENV" ]]; then
    apex_venv_name="$(basename "$VIRTUAL_ENV")"
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    apex_venv_name="$CONDA_DEFAULT_ENV"
  fi
}

# -----------------------------------------------------------------------------
# 7) GIT
# -----------------------------------------------------------------------------
apex_git_update() {
  apex_in_git=0
  apex_git_branch=""
  apex_git_dirty_wt=0
  apex_git_dirty_ix=0
  apex_git_untracked=0
  apex_git_conflict=0
  apex_git_op=""
  apex_git_up_ok=0
  apex_git_ahead=0
  apex_git_behind=0
  apex_git_stash=0

  local status_out
  status_out="$(command git status --porcelain=2 --branch 2>/dev/null)" || {
    apex_git_root=""
    apex_git_dir=""
    return
  }
  apex_in_git=1

  if (( apex_pwd_changed )) || [[ -z "$apex_git_root" ]]; then
    local root_info
    root_info="$(apex__find_git_root)"
    if [[ -n "$root_info" ]]; then
      apex_git_root="${root_info%%|*}"
      apex_git_dir="${root_info#*|}"
    else
      apex_git_root=""
      apex_git_dir=""
    fi
  fi

  local branch_head="" branch_oid="" upstream=""
  local xy="" ix="" wt=""
  local line
  while IFS= read -r line; do
    case "$line" in
      \#\ branch.head\ *)
        branch_head="${line#\# branch.head }"
        ;;
      \#\ branch.oid\ *)
        branch_oid="${line#\# branch.oid }"
        ;;
      \#\ branch.upstream\ *)
        upstream="${line#\# branch.upstream }"
        ;;
      \#\ branch.ab\ *)
        local ab a b
        ab="${line#\# branch.ab }"
        IFS=' ' read -r a b <<<"$ab"
        a="${a#+}"
        b="${b#-}"
        apex_git_ahead="${a:-0}"
        apex_git_behind="${b:-0}"
        ;;
      1\ *|2\ *)
        xy="${line[3,4]}"
        ix="${xy[1]}"
        wt="${xy[2]}"
        [[ "$ix" != "." ]] && apex_git_dirty_ix=1
        [[ "$wt" != "." ]] && apex_git_dirty_wt=1
        ;;
      u\ *)
        apex_git_conflict=1
        apex_git_dirty_ix=1
        apex_git_dirty_wt=1
        ;;
      \?\ *)
        apex_git_untracked=1
        ;;
    esac
  done <<<"$status_out"

  if [[ -n "$branch_head" && "$branch_head" != "(detached)" && "$branch_head" != "HEAD" ]]; then
    apex_git_branch="$branch_head"
  elif [[ -n "$branch_oid" ]]; then
    apex_git_branch="${branch_oid[1,7]}"
  fi

  if [[ -n "$apex_git_dir" ]]; then
    [[ -d "$apex_git_dir/rebase-apply" || -d "$apex_git_dir/rebase-merge" ]] && apex_git_op="rebase"
    [[ -f "$apex_git_dir/MERGE_HEAD" ]] && apex_git_op="merge"
    [[ -f "$apex_git_dir/CHERRY_PICK_HEAD" ]] && apex_git_op="cherry-pick"
    [[ -f "$apex_git_dir/BISECT_LOG" ]] && apex_git_op="bisect"

    if [[ -f "$apex_git_dir/logs/refs/stash" ]]; then
      local -a stash_lines
      stash_lines=(${(f)"$(<"$apex_git_dir/logs/refs/stash")"})
      apex_git_stash=$#stash_lines
    elif [[ -f "$apex_git_dir/refs/stash" ]]; then
      apex_git_stash=1
    fi
  fi

  (( apex_git_conflict )) && apex_git_op="conflict"

  if [[ -n "$upstream" && "$upstream" != "(gone)" ]]; then
    if (( apex_git_dirty_wt == 0 && apex_git_dirty_ix == 0 && apex_git_untracked == 0 && apex_git_conflict == 0 && apex_git_stash == 0 )) \
      && [[ -z "$apex_git_op" ]]; then
      [[ "$apex_git_behind" == "0" && "$apex_git_ahead" == "0" ]] && apex_git_up_ok=1
    fi
  fi
}

# -----------------------------------------------------------------------------
# 8) LEFT PROMPTLINE: IDENTITY + TERRITORY
# -----------------------------------------------------------------------------
apex_identity() {
  local is_root=0 is_ssh=0 color label
  (( EUID == 0 )) && is_root=1
  [[ -n "$SSH_CONNECTION$SSH_TTY" ]] && is_ssh=1

  if (( is_root )); then
    color="${C[PURPLE]}"
    if (( is_ssh )); then
      label="${I[ROOT]} @%m"
    else
      label="${I[ROOT]} root"
    fi
  elif (( is_ssh )); then
    color="${C[CYAN]}"
    label="${I[SSH]} %n@%m"
  else
    return 0
  fi

  print -n "%F{${color}}${S[PL_L]}%f%K{${color}}%F{${C[VOID]}}%B ${label} %b%f%k%F{${color}}${S[PL_R]}%f "
}

apex_territory() {
  print -n "%F{${C[RAZOR]}}${S[PL_L]}%f%K{${C[RAZOR]}}%F{${C[VOID]}}%B ${I[OS]}%b %F{${C[WHITE]}}%B%~%b %f%k%F{${C[RAZOR]}}${S[PL_R]}%f"
}

# -----------------------------------------------------------------------------
# 9) RIGHT PROMPT (RPROMPT): INTEL + VCS + FRICTION
# -----------------------------------------------------------------------------
apex_intel_r() {
  (( APEX[SHOW_INTEL] )) || return 0
  if [[ -n "$apex_target_sig" ]]; then
    print -n "%F{${C[CYAN]}}(${apex_target_sig})%f"
  elif [[ -n "$apex_mode_sig" ]]; then
    print -n "%F{${C[CYAN]}}(${apex_mode_sig})%f"
  elif [[ -n "$apex_venv_name" ]]; then
    print -n "%F{${C[CYAN]}}(${apex_venv_name})%f"
  fi
}

apex_vcs_r() {
  (( APEX[SHOW_VCS] )) || return 0
  (( apex_in_git )) || return 0
  local branch; branch="$(apex__escape_prompt "$apex_git_branch")"

  if [[ -n "$apex_git_op" ]]; then
    print -n "%F{${C[ALERT]}}${I[GIT]} ${branch} ${apex_git_op}%f"
    return 0
  fi

  print -n "%F{${C[CYAN]}}${I[GIT]} ${branch}%f"

  local mark=""
  (( apex_git_dirty_ix )) && mark+="+"
  (( apex_git_dirty_wt )) && mark+="!"
  (( apex_git_untracked )) && mark+="?"
  [[ -n "$mark" ]] && print -n "%F{${C[GOLD]}} ${mark}%f"

  (( apex_git_stash > 0 )) && print -n "%F{${C[MUTED]}} s${apex_git_stash}%f"

  (( apex_git_up_ok )) && print -n "%F{${C[OK]}} ✓%f"

  if (( APEX[GIT_AHEAD_BEHIND] )); then
    (( apex_git_ahead > 0 )) && print -n "%F{${C[MUTED]}} ⇡${apex_git_ahead}%f"
    (( apex_git_behind > 0 )) && print -n "%F{${C[MUTED]}} ⇣${apex_git_behind}%f"
  fi
}

apex_friction_r() {
  if (( APEX[SHOW_RO] )); then
    local ro=0
    [[ ! -w . ]] && ro=1
    if (( apex_in_git )) && [[ -n "$apex_git_root" && ! -w "$apex_git_root" ]]; then
      ro=1
    fi
    if (( ro )); then
      print -n "%F{${C[GOLD]}}${I[ROOT]} ro%f"
      return 0
    fi
  fi

  if (( APEX[SHOW_JOBS] )); then
    local -a job_pids
    job_pids=(${(f)"$(jobs -p 2>/dev/null)"})
    local jc=$#job_pids
    if (( jc > 0 )); then
      print -n "%F{${C[MUTED]}}${I[JOBS]} ${jc}%f"
      return 0
    fi
  fi
}

build_rprompt() {
  local s out=""
  local sep="%F{${C[MUTED]}} ${S[DOT]} %f"

  s="$(apex_intel_r)";    [[ -n "$s" ]] && out+="$s"
  s="$(apex_vcs_r)";      [[ -n "$s" ]] && out+="${out:+$sep}$s"
  s="$(apex_friction_r)"; [[ -n "$s" ]] && out+="${out:+$sep}$s"

  [[ -n "$out" ]] && out="%F{${C[MUTED]}}[%f${out}%F{${C[MUTED]}}]%f"
  print -n "$out"
}

# -----------------------------------------------------------------------------
# 10) RADAR (precmd)
# -----------------------------------------------------------------------------
apex_radar_aar() {
  (( APEX[SHOW_AAR] )) || return 0

  local ec=$1 cmd="$2" dur="$3"
  local -i ms=${4:-0}

  local show=0
  (( ec != 0 )) && show=1
  [[ -n "$dur" ]] && show=1
  [[ "$cmd" =~ ${APEX[OPS_RE]} ]] && show=1
  (( show )) || return 0

  local short; short="$(apex__short_cmd "$cmd")"
  short="$(apex__escape_prompt "$short")"

  local dur_color="${C[MUTED]}"
  (( ms >= ${APEX[SLOW_HARD_MS]} )) && dur_color="${C[GOLD]}"

  local dur_chunk=""
  if [[ -n "$dur" ]]; then
    if (( ms >= ${APEX[SLOW_HARD_MS]} )); then
      dur_chunk=" %F{${dur_color}}%B${dur}%b%f"
    else
      dur_chunk=" %F{${dur_color}}${dur}%f"
    fi
  fi

  # Session commands: don't scream in red for “rc:1”
  if [[ "$cmd" =~ ${APEX[SESSION_RE]} ]]; then
    if (( ec == 0 )); then
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[OK]}}${I[RET]}%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
    else
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[GOLD]}}${I[RET]}%f %F{${C[WHITE]}}${short}%f %F{${C[MUTED]}}rc:${ec}%f${dur_chunk}"
    fi
    return 0
  fi

  if (( ec == 0 )); then
    print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[OK]}}✓%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
    return 0
  fi

  # Signals: 128 + signal number
  case $ec in
    130) # SIGINT (Ctrl+C)
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[CYAN]}}^C%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
      ;;
    141) # SIGPIPE
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[MUTED]}}PIPE%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
      ;;
    143) # SIGTERM
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[GOLD]}}TERM%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
      ;;
    *) 
      print -P "%F{${C[MUTED]}}${I[RADAR]}%f %F{${C[ALERT]}}✘ ${ec}%f %F{${C[WHITE]}}${short}%f${dur_chunk}"
      ;;
  esac
}

apex_radar_context_burst() {
  (( APEX[SHOW_CONTEXT_BURST] )) || return 0

  local proj_sig; proj_sig="$(apex__project_sig 2>/dev/null || print -r -- "")"

  local emit=0
  if (( apex_startup_done == 0 )); then
    (( APEX[STARTUP_BURST] )) && emit=1
  fi
  (( apex_pwd_changed )) && emit=1
  [[ "$apex_venv_name" != "$apex_prev_venv_name" ]] && emit=1
  [[ "$apex_target_sig" != "$apex_prev_target_sig" ]] && emit=1
  (( apex_in_git != apex_prev_in_git )) && emit=1
  [[ "$apex_git_branch" != "$apex_prev_git_branch" ]] && emit=1
  [[ "$apex_git_op" != "$apex_prev_git_op" ]] && emit=1
  [[ "$proj_sig" != "$apex_prev_proj_sig" ]] && emit=1

  (( emit )) || return 0

  # If nothing to say, say nothing.
  if [[ -z "$proj_sig" && -z "$apex_venv_name" && -z "$apex_target_sig" ]] && (( apex_in_git == 0 )); then
    apex_pwd_changed=0
    apex_startup_done=1
    return 0
  fi

  local out="%F{${C[MUTED]}}${I[RADAR]}%f "

  # Git first
  if (( apex_in_git )); then
    local branch; branch="$(apex__escape_prompt "$apex_git_branch")"
    if [[ -n "$apex_git_op" ]]; then
      out+="%F{${C[ALERT]}}${I[GIT]} ${branch} ${apex_git_op}%f"
    else
      out+="%F{${C[CYAN]}}${I[GIT]} ${branch}%f"
    fi
  fi

  [[ -n "$proj_sig" ]]        && out+="${out:+ %F{${C[MUTED]}}·%f }%F{${C[MUTED]}}${proj_sig}%f"
  [[ -n "$apex_venv_name" ]]  && out+="${out:+ %F{${C[MUTED]}}·%f }%F{${C[CYAN]}}(${apex_venv_name})%f"
  [[ -n "$apex_target_sig" ]] && out+="${out:+ %F{${C[MUTED]}}·%f }%F{${C[CYAN]}}(${apex_target_sig})%f"

  print -P "$out"

  apex_prev_venv_name="$apex_venv_name"
  apex_prev_target_sig="$apex_target_sig"
  apex_prev_in_git="$apex_in_git"
  apex_prev_git_branch="$apex_git_branch"
  apex_prev_git_op="$apex_git_op"
  apex_prev_proj_sig="$proj_sig"

  apex_pwd_changed=0
  apex_startup_done=1
}

# -----------------------------------------------------------------------------
# 11) HOOKS
# -----------------------------------------------------------------------------
apex_preexec_hook() {
  apex_has_run_cmd=1
  apex_cmd_start="$(apex__now_float)"
  apex_last_cmd="$1"
}

apex_chpwd_hook() {
  apex_pwd_changed=1
}

apex_precmd_hook() {
  local ec=$?

  apex_update_intel
  apex_git_update

  # Did a command actually run since the last prompt?
  local ran=0
  (( apex_has_run_cmd )) && ran=1

  if (( ran )); then
    local now; now="$(apex__now_float)"
    local -i ms=0
    local -F delta=0.0
    if [[ -n "$now" ]]; then
      delta=$(( now - apex_cmd_start ))
      (( delta < 0 )) && delta=0
      ms=$(( delta * 1000 ))
    fi

    # Show time if: slow OR ops OR failed.
    local dur=""
    if (( ms >= ${APEX[SLOW_SOFT_MS]} )) || [[ "$apex_last_cmd" =~ ${APEX[OPS_RE]} ]] || (( ec != 0 )); then
      dur="$(printf "%.2fs" $(( ms / 1000.0 )))"
    fi

    apex_radar_aar $ec "$apex_last_cmd" "$dur" $ms

    apex_has_run_cmd=0

    # Spacer between AAR and context burst / prompt.
    print -r -- ""
  fi

  apex_radar_context_burst
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec apex_preexec_hook
add-zsh-hook precmd  apex_precmd_hook
add-zsh-hook chpwd   apex_chpwd_hook

# -----------------------------------------------------------------------------
# 12) PROMPT BUILD
# -----------------------------------------------------------------------------
build_prompt() {
  local ec=$?

  # Line 1: identity + territory (left)
  print -n "$(apex_identity)"
  print -n "$(apex_territory)"
  print -n $'
'

  # Line 2: trigger posture
  if (( EUID == 0 )); then
    print -n "%F{${C[PURPLE]}}❯%f "
  elif (( ec != 0 )); then
    print -n "%F{${C[ALERT]}}❯%f "
  else
    print -n "%F{${C[CYAN]}}❯%f "
  fi
}

PROMPT='$(build_prompt)'
RPROMPT='$(build_rprompt)'