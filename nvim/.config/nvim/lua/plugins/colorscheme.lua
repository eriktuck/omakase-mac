-- omakase-mac: match the Catppuccin Mocha theme used by Ghostty and tmux.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      integrations = {
        telescope = true,
        which_key = true,
        lazygit = true,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
