-- Chroma theme plugin spec for LazyVim.
--
-- The Chroma colorscheme is a self-contained Lua file (no runtime deps) that
-- lives at ~/.config/nvim/colors/chroma-<theme>.lua. beautify/install.sh
-- copies it there; this spec just registers it as the active colorscheme so
-- LazyVim boots straight into Chroma.
--
-- To switch theme: running  ./beautify/install.sh --theme <name>  copies the
-- matching chroma.lua over ~/.config/nvim/colors/chroma.lua, then this spec
-- re-applies it on the next nvim start.
return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      opts.colorscheme = "chroma"
      return opts
    end,
  },
}