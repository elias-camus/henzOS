-- henzOS emerald theme for Neovim
-- Place in ~/.config/nvim/lua/plugins/colorscheme.lua to override LazyVim default
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.bg = "#0b0f10"
        colors.bg_dark = "#11181a"
        colors.fg = "#cfd7d6"
        colors.green = "#2bd9a5"
        colors.red = "#d96b5f"
        colors.comment = "#8c9797"
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
