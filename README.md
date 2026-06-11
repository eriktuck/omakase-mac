# omakase-mac

A curated, reproducible **Apple-Silicon developer environment** — an "omakase" port of the
[Omarchy](https://omarchy.org) philosophy to macOS. Keyboard-centric, tiling, and built entirely on
fast cross-platform CLI tools.

See [`SPEC.md`](./SPEC.md) for the full design rationale.

## Architecture

Three configuration layers:

| Layer        | Tool       | Responsibility                                            |
| ------------ | ---------- | --------------------------------------------------------- |
| **Packages** | `Brewfile` | Declarative list of CLI tools, fonts, and GUI apps.       |
| **Config**   | GNU Stow   | Symlinks dotfiles from this repo into `~` and `~/.config`. |
| **OS**       | `defaults` | `macos/defaults.sh` applies system preferences.           |

## Install (fresh machine)

```sh
git clone <this-repo> ~/.omakase-mac
cd ~/.omakase-mac
./install.sh
```

`install.sh` is **idempotent** — re-run it any time to converge the machine back to this config.

## Toolchain

Ghostty (terminal) · Tmux (multiplexer) · AeroSpace (tiling WM) · Neovim/LazyVim (editor) ·
Starship (prompt) · eza · bat · fzf · ripgrep · fd · zoxide · lazygit.

## How it's organized

Each top-level directory is a **stow package** mirroring the target path under `$HOME`:

```
zsh/.zshrc                          -> ~/.zshrc
zsh/.zprofile                       -> ~/.zprofile
ghostty/.config/ghostty/config      -> ~/.config/ghostty/config
tmux/.config/tmux/tmux.conf         -> ~/.config/tmux/tmux.conf
aerospace/.config/aerospace/...     -> ~/.config/aerospace/...
starship/.config/starship.toml      -> ~/.config/starship.toml
nvim/.config/nvim/                  -> ~/.config/nvim/   (vendored LazyVim)
```

Because the repo lives directly in `$HOME`, `stow <pkg>` targets `~` automatically (no `--target`).

## Manual post-install steps

`install.sh` prints these; they require GUI interaction and can't be fully scripted:

1. **Set git identity:** `git config --global user.name "…"` / `user.email "…"`.
2. **Grant AeroSpace Accessibility** permission (System Settings → Privacy & Security → Accessibility),
   then launch it.
3. **Grant Ghostty Accessibility** permission so the global `Ctrl+Esc` quick-terminal hotkey works.
4. **Restart your shell** (or open a new Ghostty window).

## Day-to-day

- Add a tool: edit `Brewfile`, run `brew bundle`, commit.
- Change a config: edit the file in this repo (the symlink means it's live immediately), commit.
- Update Neovim plugins: `:Lazy update` in nvim, then commit the changed `lazy-lock.json`.
- Re-apply OS prefs after an macOS upgrade: `./macos/defaults.sh`.
