# omakase-mac — declarative package manifest
# Apply with: brew bundle --file=Brewfile
# Refresh after adding tools; keep this list curated and intentional.

# --- Taps ---
tap "nikitabobko/tap"                 # AeroSpace tiling window manager
tap "FelixKratz/formulae"             # SketchyBar status bar

# --- CLI core ---
brew "stow"                           # symlink farm manager (config layer)
brew "neovim"                         # editor / IDE (LazyVim)
brew "tmux"                           # terminal multiplexer
brew "starship"                       # cross-shell prompt
brew "eza"                            # modern ls
brew "bat"                            # modern cat
brew "fzf"                            # fuzzy finder
brew "ripgrep"                        # fast search (rg)
brew "fd"                             # fast find
brew "jq"                             # JSON processor (used by the Claude statusline)
brew "zoxide"                         # smarter cd (z)
brew "lazygit"                        # terminal git UI
brew "git"                            # modern git over Apple's bundled build
brew "gh"                             # GitHub CLI (PRs, issues, gh api)

# --- Networking ---
brew "tailscale"                      # mesh VPN (already in use — preserved)

# --- Development ---
brew "uv"                             # Astral's fast Python package/project manager
brew "node"                           # Node.js runtime (npm bundled; we default to pnpm)
brew "pnpm"                           # preferred JS package manager — no auto-run install scripts
cask "docker-desktop"                 # Docker Desktop: CLI + engine + GUI (daemon included)
cask "temurin@21"                     # Eclipse Temurin JDK 21 (LTS), macOS-registered
cask "claude-code"                    # Claude Code CLI (the `claude` binary)

# --- GUI apps ---
cask "ghostty"                        # GPU-accelerated terminal
cask "nikitabobko/tap/aerospace"      # i3-like tiling WM
cask "raycast"                        # launcher / Spotlight replacement (cmd+space)
cask "linearmouse"                    # kills mouse scroll acceleration (config stowed below)

# --- Fonts ---
cask "font-0xproto-nerd-font"
cask "font-geist-mono-nerd-font"
