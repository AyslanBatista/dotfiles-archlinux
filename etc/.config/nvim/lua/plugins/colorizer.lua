return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    filetypes = { "*" },
    user_default_options = {
      RGB = true, -- #RGB
      RRGGBB = true, -- #RRGGBB
      RRGGBBAA = true, -- #RRGGBBAA
      names = false, -- desativo "Red", "Blue" -- evita falsos positivos em código
      rgb_fn = true, -- rgb() rgba()
      hsl_fn = true, -- hsl() hsla()
      mode = "background", -- fundo colorido, igual VSCode
    },
  },
}
