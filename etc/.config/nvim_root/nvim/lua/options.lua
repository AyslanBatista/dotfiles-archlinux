local opt = vim.opt

-- Aparência
opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "80"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.showmode = false        -- Escondemos o -- INSERT -- porque a statusline já mostra
opt.cmdheight = 1
opt.pumheight = 10          -- Altura máxima do popup de completion

-- Indentação
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Busca
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Misc
opt.updatetime = 250
opt.timeoutlen = 400
opt.undofile = true
opt.swapfile = false
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.fileencoding = "utf-8"
opt.confirm = true           -- Pergunta antes de fechar arquivo não salvo
