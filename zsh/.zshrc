# omakase-mac — interactive shell config
# Managed via GNU Stow from ~/.omakase-mac/zsh/.zshrc

# --- PATH ---
export PATH="$HOME/.local/bin:$PATH"

# --- Editor ---
export EDITOR="nvim"
export VISUAL="nvim"

# --- History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY          # share history across sessions
setopt INC_APPEND_HISTORY     # write as commands run, not on exit
setopt HIST_IGNORE_DUPS       # don't record an entry that duplicates the previous
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate entries
setopt HIST_REDUCE_BLANKS     # trim superfluous whitespace
setopt HIST_VERIFY            # don't execute immediately on history expansion

# --- Completion ---
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive

# --- Aliases: modern replacements ---
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias la="eza --icons --group-directories-first -la"
alias lt="eza --icons --tree --level=2"
alias cat="bat"
alias lg="lazygit"
alias vim="nvim"
alias vi="nvim"

# --- Aliases: shortcuts (per SPEC) ---
alias c="clear"
alias cx="chmod +x"
alias ..="cd .."
alias ...="cd ../.."
alias reload="source ~/.zshrc"

# --- Functions: tmux dev layout (from omarchy) ---
# Usage: tdl <ai> [<second_ai>]   e.g. `tdl claude`
# Editor (nvim) on the left, AI on the right (30%), terminal across the bottom (15%).
# A second AI splits the right-hand pane, giving a 4-pane layout (e.g. `tdl claude codex`).
tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <ai> [<second_ai>]   e.g. tdl claude"; return 1; }
  [[ -z $TMUX ]] && { echo "tdl must be run inside tmux."; return 1; }

  local current_dir="$PWD"
  local editor_pane ai_pane ai2_pane
  local ai="$1" ai2="$2"

  editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  # Bottom terminal pane (15%)
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"

  # Right-hand AI pane (30%)
  ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')

  # Optional second AI, splitting the AI pane vertically
  if [[ -n $ai2 ]]; then
    ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi

  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux send-keys -t "$editor_pane" "${EDITOR:-nvim} ." C-m
  tmux select-pane -t "$editor_pane"
}

# Tmux dev square: 2x2 layout — editor / git diff (top), terminal / claude (bottom).
# Usage: tds
tds() {
  [[ -n $1 ]] && { echo "Usage: tds"; return 1; }
  [[ -z $TMUX ]] && { echo "tds must be run inside tmux."; return 1; }

  local current_dir="$PWD"
  local editor_pane diff_pane terminal_pane ai_pane

  editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"

  terminal_pane=$(tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  diff_pane=$(tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  ai_pane=$(tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')

  tmux send-keys -t "$editor_pane" -l "${EDITOR:-nvim} ."
  tmux send-keys -t "$editor_pane" C-m
  tmux send-keys -t "$diff_pane" -l "git diff"
  tmux send-keys -t "$diff_pane" C-m
  tmux send-keys -t "$ai_pane" -l "claude"
  tmux send-keys -t "$ai_pane" C-m

  tmux select-pane -t "$editor_pane"
}

# Tmux dev layout multi: open one tdl window per subdirectory of the current dir.
# Usage: tdlm <ai> [<second_ai>]   e.g. `tdlm claude`
tdlm() {
  [[ -z $1 ]] && { echo "Usage: tdlm <ai> [<second_ai>]   e.g. tdlm claude"; return 1; }
  [[ -z $TMUX ]] && { echo "tdlm must be run inside tmux."; return 1; }

  local ai="$1" ai2="$2"
  local base_dir="$PWD"
  local first=true

  # Rename the session to the current dir (tmux disallows dots/colons)
  tmux rename-session "$(basename "$base_dir" | tr '.:' '--')"

  # (N) = null-glob so an empty dir doesn't trigger zsh's "no matches found"
  for dir in "$base_dir"/*/(N); do
    [[ -d $dir ]] || continue
    local dirpath="${dir%/}"

    if $first; then
      # Reuse the current window for the first project
      tmux send-keys -t "$TMUX_PANE" "cd '$dirpath' && tdl $ai $ai2" C-m
      first=false
    else
      local pane_id
      pane_id=$(tmux new-window -c "$dirpath" -P -F '#{pane_id}')
      tmux send-keys -t "$pane_id" "tdl $ai $ai2" C-m
    fi
  done
}

# Tmux swarm layout: N tiled panes all running the same command (great for AI fan-out).
# Usage: tsl <pane_count> <command>   e.g. `tsl 4 claude`
tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>   e.g. tsl 4 claude"; return 1; }
  [[ -z $TMUX ]] && { echo "tsl must be run inside tmux."; return 1; }

  local count="$1" cmd="$2"
  local current_dir="$PWD"
  local -a panes

  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"
  panes+=("$TMUX_PANE")

  # zsh arrays are 1-indexed: panes[1] is first, panes[-1] is last
  while (( ${#panes[@]} < count )); do
    local new_pane split_target="${panes[-1]}"
    new_pane=$(tmux split-window -h -t "$split_target" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[1]}" tiled
  done

  local pane
  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done

  tmux select-pane -t "${panes[1]}"
}

# --- Tool initialization ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# fzf: key bindings (Ctrl-R history, Ctrl-T files) and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
