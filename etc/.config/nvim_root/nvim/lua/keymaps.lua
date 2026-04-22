local map = vim.keymap.set

vim.g.mapleader = " "

-- Navegação entre splits (igual ao LazyVim)
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Limpa highlight de busca com Esc
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Salva com Ctrl+S
map({ "n", "i" }, "<C-s>", "<cmd>w<CR>")

-- Indentação em visual mantém seleção
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move linhas em visual (igual ao LazyVim)
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<CR>")
map("n", "<S-l>", "<cmd>bnext<CR>")

-- Netrw como file explorer (built-in, substitui Neo-tree)
map("n", "<leader>e", "<cmd>Lexplore<CR>", { desc = "File explorer" })
