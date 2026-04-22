-- =============================================================================
-- OPTIONS
-- Manter configurações sensatas sem alterar comportamento básico do Vim
-- =============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Informa ao LazyVim qual LSP e formatter usar para Python.
vim.g.lazyvim_python_lsp = "basedpyright"
vim.g.lazyvim_python_ruff = "ruff"

-- =============================================================================
-- APARÊNCIA
-- =============================================================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.colorcolumn = "100"
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

-- =============================================================================
-- INDENTAÇÃO
-- =============================================================================
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- =============================================================================
-- BUSCA
-- =============================================================================
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- =============================================================================
-- PERFORMANCE
-- =============================================================================
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- =============================================================================
-- CLIPBOARD E ARQUIVOS
-- =============================================================================
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- =============================================================================
-- MISC
-- =============================================================================
vim.opt.spell = false

-- Splits abrem à direita e abaixo (comportamento intuitivo)
vim.opt.splitright = true
vim.opt.splitbelow = true

-- =============================================================================
-- FILETYPES COM INDENTAÇÃO 2 ESPAÇOS
-- =============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "json", "yaml", "html", "javascript", "typescript", "css" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- =============================================================================
-- ASSEMBLY: sem colorcolumn (linhas estruturadas em colunas mnemônico/operando)
-- =============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "asm", "nasm" },
  callback = function()
    vim.opt_local.colorcolumn = ""
  end,
})
