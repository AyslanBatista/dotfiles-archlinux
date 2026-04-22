-- =============================================================================
-- ESSENTIAL PLUGINS
-- =============================================================================
--
-- ARQUITETURA:
--   Os extras oficiais do LazyVim são importados em lazy.lua (config/lazy.lua),
--   na ordem correta exigida pelo LazyVim:
--     1. lazyvim.plugins (core)
--     2. lazyvim.plugins.extras.* (extras — devem vir antes dos plugins customizados)
--     3. plugins (este arquivo e os demais em lua/plugins/)
--
--   Aqui ficam apenas overrides e plugins que os extras não cobrem:
--     - Overrides específicos (configurações que os extras não cobrem)
--     - Plugins que os extras não incluem (hex.nvim, toggleterm, etc.)
--     - Customizações visuais (tokyonight, neo-tree, which-key)
--
-- O que os extras entregam automaticamente (não precisa configurar aqui):
--   Python   → basedpyright + ruff (LSP + format + lint)
--   Rust     → rust-analyzer + crates.nvim + rustfmt
--   C/C++    → clangd + clangd_extensions + clang-format
--   DAP      → nvim-dap + nvim-dap-ui + codelldb (via Mason)
--   Markdown → render-markdown.nvim + markdown-preview.nvim + prettier

return {

  -- ===========================================================================
  -- TEMA: TOKYO NIGHT
  -- ===========================================================================
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "moon",
      transparent = true,
      on_highlights = function(hl, c)
        -- NeoTree transparente
        hl.NeoTreeNormal = { bg = "NONE" }
        hl.NeoTreeNormalNC = { bg = "NONE" }
        hl.NeoTreeEndOfBuffer = { bg = "NONE" }
      end,
    },
  },

  -- Informa ao LazyVim qual colorscheme usar
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- ===========================================================================
  -- TERMINAL INTEGRADO
  -- Snacks terminal está desabilitado abaixo — usamos toggleterm.
  -- ===========================================================================
  {
    "akinsho/toggleterm.nvim",
    config = function()
      require("toggleterm").setup({
        size = 15,
        direction = "horizontal",
        start_in_insert = true,
        open_mapping = false,
      })

      -- Transparência real do terminal via winhighlight.
      -- TerminalNormal não é um grupo válido no Neovim — a abordagem correta
      -- é sobrescrever o highlight do buffer no momento em que o terminal abre.
      vim.api.nvim_create_autocmd("TermOpen", {
        callback = function()
          vim.opt_local.winhighlight = "Normal:NormalFloat,NormalNC:NormalFloat"
        end,
      })
    end,
  },

  -- ===========================================================================
  -- FILE EXPLORER
  -- ===========================================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      window = {
        position = "left",
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
        },
      },
    },
  },

  -- ===========================================================================
  -- LSP — apenas overrides e servidores que os extras não cobrem
  --
  -- NÃO defina pyright/basedpyright, rust_analyzer ou clangd aqui:
  -- os extras oficiais já configuram esses servidores com settings melhores.
  -- Definir novamente causaria merge duplicado ou comportamento inesperado.
  --
  -- asm_lsp não está em nenhum extra oficial → mantido aqui.
  -- Requer um arquivo .asm-lsp.toml no root do projeto. Exemplo mínimo:
  --   [[assembler]]
  --   name = "nasm"
  -- Documentação: https://github.com/bergercookie/asm-lsp
  -- ===========================================================================
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
      servers = {
        asm_lsp = {},
        basedpyright = {
          settings = {
            basedpyright = {
              typeCheckingMode = "basic", -- "off", "basic", "standard", "strict"
              analysis = {
                reportUnknownMemberType = false,
                reportUnknownVariableType = false,
                reportUnknownArgumentType = false,
              },
            },
          },
        },
      },
    },
  },

  -- ===========================================================================
  -- FORMATAÇÃO
  -- NOTA: não use config = function() aqui — o LazyVim gerencia o conform
  -- internamente e chamar setup() manualmente quebra o sistema de formatação.
  --
  -- Python (black/isort) removidos: o extra lang.python configura ruff
  -- automaticamente via conform. Ruff é mais rápido e já unifica lint+format.
  --
  -- Rust (rustfmt) e C/C++ (clang-format) também são gerenciados pelos extras.
  -- Aqui mantemos apenas Lua, que nenhum extra cobre.
  -- ===========================================================================
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
      },
    },
  },

  -- ===========================================================================
  -- GIT
  -- ===========================================================================
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 1000,
      },
    },
  },

  -- ===========================================================================
  -- COMPLETION (blink.cmp)
  -- ===========================================================================
  {
    "saghen/blink.cmp",
    opts = {
      signature = {
        enabled = false,
      },
      completion = {
        documentation = {
          auto_show = false,
        },
      },
      keymap = {
        ["<Tab>"] = { "accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-Space>"] = { "show" },
        ["<C-e>"] = { "hide" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-d>"] = { "show_documentation", "hide_documentation" },
      },
    },
  },

  -- ===========================================================================
  -- WHICH-KEY
  -- ===========================================================================
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        -- <leader>w é usado pelo LazyVim como +windows (proxy de <C-w>).
        -- Ocultamos o grupo para que <leader>w funcione como "Save" no keymaps.lua
        -- sem conflito visual no which-key.
        { "<leader>w", hidden = true },
        ["<leader>f"] = { name = "+find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>c"] = { name = "+code" },
        ["<leader>t"] = { name = "+terminal" },
        ["<leader>s"] = { name = "+split" },
        ["<leader>r"] = { name = "+rust/hints" },
        ["<leader>o"] = { name = "+outline" },
        ["<leader>d"] = { name = "+debug" },
      },
    },
  },

  -- ===========================================================================
  -- TREESITTER
  -- Os extras de linguagem já instalam os parsers necessários para Python,
  -- Rust e C/C++. Aqui adicionamos os que nenhum extra cobre.
  -- ===========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua",
        "javascript",
        "typescript",
        "html",
        "css",
        "json",
        "yaml",
        "markdown",
        "bash",
        "asm",
        "nasm",
      },
    },
  },

  -- ===========================================================================
  -- HEX EDITOR — análise de binários diretamente no Neovim
  -- Uso: :HexToggle para alternar entre visualização normal e hexadecimal
  -- ===========================================================================
  {
    "RaafatTurki/hex.nvim",
    cmd = { "HexToggle", "HexDump", "HexAssemble" },
    config = function()
      require("hex").setup()
    end,
  },

  -- ===========================================================================
  -- SNACKS — desabilitar terminal e explorer (usamos toggleterm + neo-tree)
  -- ===========================================================================
  {
    "folke/snacks.nvim",
    opts = {
      terminal = { enabled = false },
      explorer = { enabled = false },
    },
  },

  -- ===========================================================================
  -- MÚLTIPLOS CURSORES
  -- ===========================================================================
  {
    "mg979/vim-visual-multi",
    branch = "master",
  },

  -- ===========================================================================
  -- OUTLINE LATERAL — navegação em arquivos grandes de C/C++/Assembly
  -- ===========================================================================
  {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "lsp", "treesitter" },
    },
    keys = {
      { "<leader>o", "<cmd>AerialToggle<CR>", desc = "Toggle outline" },
    },
  },

  -- ===========================================================================
  -- nvim-lint: desabilitado — ruff via LSP (extra lang.python) já cobre lint.
  -- Para reativar: remova esta entrada e crie plugins/lint.lua com sua config.
  -- ===========================================================================
  {
    "mfussenegger/nvim-lint",
    enabled = false,
  },
}
