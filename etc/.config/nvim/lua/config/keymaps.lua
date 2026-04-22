-- =============================================================================
-- KEYMAPS
-- REGRA: nunca remapear comandos básicos do Vim.
-- Usar <leader> para funcionalidades extras.
-- =============================================================================

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- =============================================================================
-- NAVEGAÇÃO DE ARQUIVOS
-- Usando Snacks Picker (padrão LazyVim atual) — mais rápido que Telescope.
-- O LazyVim já mapeia <leader><leader> para find_files e <leader>/ para grep,
-- mas mantemos aliases explícitos para muscle memory.
-- =============================================================================
map("n", "<leader>ff", function() Snacks.picker.files() end,           { desc = "Find files" })
map("n", "<leader>fg", function() Snacks.picker.grep() end,            { desc = "Find text in files" })
map("n", "<leader>fr", function() Snacks.picker.recent() end,          { desc = "Find recent files" })
map("n", "<leader>fb", function() Snacks.picker.buffers() end,         { desc = "Find buffers" })
map("n", "<leader>e",  "<cmd>Neotree toggle<CR>",                      { desc = "Toggle file explorer" })

-- =============================================================================
-- SALVAR / SAIR
-- O LazyVim usa <leader>w como proxy de <C-w> (+windows).
-- Usamos vim.keymap.set diretamente para garantir precedência sobre o LazyVim.
-- O grupo which-key está oculto em essential.lua para evitar conflito visual.
-- =============================================================================
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>",  { noremap = true, silent = true, desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>",             { desc = "Quit" })
map("n", "<leader>x", "<cmd>x<CR>",             { desc = "Save and quit" })

-- =============================================================================
-- LSP ACTIONS
-- K, gd e gr são gerenciados pelo LazyVim com Trouble integrado.
-- Não remapeie gd/gr aqui para não quebrar o comportamento melhorado.
-- =============================================================================
map("n", "<F2>",      "<cmd>lua vim.lsp.buf.rename()<CR>",      { desc = "Rename symbol" })
map("n", "<leader>ca","<cmd>lua vim.lsp.buf.code_action()<CR>", { desc = "Code actions" })
map("n", "K",         "<cmd>lua vim.lsp.buf.hover()<CR>",       { desc = "Show hover info" })

-- =============================================================================
-- NAVEGAÇÃO POR BUFFERS
-- =============================================================================
map("n", "]b", "<cmd>bnext<CR>",     { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bd<CR>",{ desc = "Delete buffer" })

-- =============================================================================
-- TERMINAL (toggleterm)
-- =============================================================================
map("n", "<leader>tt", "<cmd>ToggleTerm<CR>",                    { desc = "Toggle terminal" })
map("n", "<leader>tf", "<cmd>ToggleTerm direction=float<CR>",    { desc = "Float terminal" })
map("t", "<leader>tt", "<cmd>ToggleTerm<CR>",                    { desc = "Toggle terminal" })
map("n", "<C-/>",      "<cmd>ToggleTerm<CR>",                    { desc = "Toggle terminal" })
map("t", "<C-/>",      "<cmd>ToggleTerm<CR>",                    { desc = "Toggle terminal" })

-- =============================================================================
-- FORMATAÇÃO
-- Chamada direta ao conform.nvim — sem feedkeys() frágil.
-- lsp_fallback = true: se não houver formatter configurado para o filetype,
-- cai no LSP como fallback automático.
-- =============================================================================
map("n", "<leader>fm", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format document" })

-- =============================================================================
-- CLEAR SEARCH HIGHLIGHT
-- =============================================================================
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- =============================================================================
-- SPLITS
-- =============================================================================
map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertically" })
map("n", "<leader>sh", "<cmd>split<CR>",  { desc = "Split horizontally" })

-- =============================================================================
-- INLAY HINTS — toggle manual por buffer
-- Funciona para qualquer LSP (clangd, rust-analyzer, basedpyright, etc.)
-- =============================================================================
map("n", "<leader>rh", function()
  vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
  vim.notify("Inlay hints disabled", vim.log.levels.INFO)
end, { desc = "Disable inlay hints" })

map("n", "<leader>rH", function()
  vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
  vim.notify("Inlay hints enabled", vim.log.levels.INFO)
end, { desc = "Enable inlay hints" })

-- =============================================================================
-- DAP — DEBUGGING
-- Requer o extra lazyvim.plugins.extras.dap.core (ativado em essential.lua).
-- codelldb (C/C++/Rust) e nvim-dap-python (Python) são instalados via Mason.
--
-- Workflow básico:
--   <F5>        → inicia / continua a sessão de debug
--   <F10>       → step over (pula para próxima linha, sem entrar em funções)
--   <F11>       → step into (entra dentro da função)
--   <F12>       → step out  (sai da função atual)
--   <leader>db  → toggle breakpoint na linha atual
--   <leader>dB  → breakpoint condicional (pede expressão)
--   <leader>dr  → abre o REPL do DAP (avalia expressões durante debug)
--   <leader>dl  → relança a última sessão de debug
--   <leader>du  → toggle DAP UI (janelas de variáveis, stack, etc.)
-- =============================================================================
map("n", "<F5>",  function() require("dap").continue() end,           { desc = "DAP: Continue" })
map("n", "<F10>", function() require("dap").step_over() end,          { desc = "DAP: Step over" })
map("n", "<F11>", function() require("dap").step_into() end,          { desc = "DAP: Step into" })
map("n", "<F12>", function() require("dap").step_out() end,           { desc = "DAP: Step out" })

map("n", "<leader>db", function() require("dap").toggle_breakpoint() end,        { desc = "Debug: Toggle breakpoint" })
map("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional breakpoint" })

map("n", "<leader>dr", function() require("dap").repl.open() end,     { desc = "Debug: Open REPL" })
map("n", "<leader>dl", function() require("dap").run_last() end,      { desc = "Debug: Run last" })
map("n", "<leader>du", function() require("dapui").toggle() end,      { desc = "Debug: Toggle UI" })

-- Terminar sessão e fechar UI
map("n", "<leader>dq", function()
  require("dap").terminate()
  require("dapui").close()
end, { desc = "Debug: Quit session" })
