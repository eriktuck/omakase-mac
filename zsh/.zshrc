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

# --- Tool initialization ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# fzf: key bindings (Ctrl-R history, Ctrl-T files) and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
