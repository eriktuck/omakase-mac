#!/usr/bin/env bash
# Claude Code statusLine — mirrors Starship prompt style
# Reads JSON from stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# --- Directory (bold cyan) ---
# Show path relative to project root if inside one, otherwise use cwd
if [ -n "$project_dir" ] && [ "$cwd" != "$project_dir" ]; then
  rel="${cwd#"$project_dir"/}"
  if [ "$rel" = "$cwd" ]; then
    dir_display="$cwd"
  else
    dir_display="$(basename "$project_dir")/$rel"
  fi
else
  dir_display="$cwd"
fi
# Abbreviate the home directory as ~
dir_display="${dir_display/#$HOME/~}"
# Truncate to last 3 path components
dir_display=$(echo "$dir_display" | awk -F/ '{
  n=NF; if(n<=3) print $0; else { out=$( n-2)"/"$(n-1)"/"$n; print "..."out }
}' 2>/dev/null || echo "$dir_display")

# --- Git branch & status (skip optional locks) ---
branch=""
git_dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    git_dirty="!"
  fi
fi

# --- Context window (bar that fills toward 100% + numeric value) ---
ctx_part=""
if [ -n "$used_pct" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  width=10
  filled=$(( pct_int * width / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( width - filled ))
  fbar=""; i=0; while [ "$i" -lt "$filled" ]; do fbar="${fbar}█"; i=$((i+1)); done
  ebar=""; i=0; while [ "$i" -lt "$empty"  ]; do ebar="${ebar}░"; i=$((i+1)); done
  # dim label/brackets/empty, bold-yellow filled and value
  ctx_part=$(printf ' \033[2mctx:\033[1;33m%s\033[0;2m%s\033[0;2m \033[1;33m%d%%\033[0m' \
                     "$fbar" "$ebar" "$pct_int")
fi

# --- Assemble with ANSI colors ---
# cyan="\033[36m", purple="\033[35m", yellow="\033[33m", reset="\033[0m", bold="\033[1m"
line=""
line="${line}$(printf '\033[1;36m%s\033[0m' "$dir_display")"

if [ -n "$branch" ]; then
  line="${line} $(printf '\033[1;35m %s\033[0m' "$branch")"
  if [ -n "$git_dirty" ]; then
    line="${line}$(printf '\033[1;33m%s\033[0m' "$git_dirty")"
  fi
fi

if [ -n "$model" ]; then
  line="${line} $(printf '\033[2m%s\033[0m' "$model")"
fi

if [ -n "$ctx_part" ]; then
  line="${line}${ctx_part}"
fi

printf '%s' "$line"
