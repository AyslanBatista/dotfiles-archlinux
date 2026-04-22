local c = {
    bg      = "#1e2030",
    fg      = "#c8d3f5",
    blue    = "#82aaff",
    green   = "#c3e88d",
    yellow  = "#ffc777",
    red     = "#ff757f",
    magenta = "#c099ff",
    cyan    = "#86e1fc",
    dark    = "#444a6a",
}

-- Mapa de modo -> { label, cor }
local modes = {
    n      = { "NORMAL",   c.blue },
    i      = { "INSERT",   c.green },
    v      = { "VISUAL",   c.magenta },
    V      = { "V-LINE",   c.magenta },
    [""]  = { "V-BLOCK",  c.magenta },
    c      = { "COMMAND",  c.yellow },
    s      = { "SELECT",   c.cyan },
    S      = { "S-LINE",   c.cyan },
    R      = { "REPLACE",  c.red },
    r      = { "REPLACE",  c.red },
    t      = { "TERMINAL", c.cyan },
    ["!"]  = { "SHELL",    c.yellow },
}

local function mode_info()
    local m = vim.fn.mode()
    return modes[m] or { m, c.fg }
end

local function hl(name, fg, bg, bold)
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg, bold = bold })
end

-- Define highlight groups da statusline
local function setup_hls()
    hl("StMode",     c.bg,  c.blue,    true)
    hl("StModeN",    c.bg,  c.blue,    true)
    hl("StModeI",    c.bg,  c.green,   true)
    hl("StModeV",    c.bg,  c.magenta, true)
    hl("StModeC",    c.bg,  c.yellow,  true)
    hl("StModeR",    c.bg,  c.red,     true)
    hl("StModeT",    c.bg,  c.cyan,    true)
    hl("StFile",     c.fg,  c.dark,    false)
    hl("StGit",      c.yellow, c.bg,   false)
    hl("StInfo",     c.cyan,   c.bg,   false)
    hl("StPos",      c.fg,  c.dark,    false)
    hl("StBg",       c.fg,  c.bg,      false)
end

local mode_to_hl = {
    n = "StModeN", i = "StModeI",
    v = "StModeV", V = "StModeV", [""] = "StModeV",
    c = "StModeC", R = "StModeR", r = "StModeR",
    t = "StModeT",
}

_G.Statusline = function()
    local mi = mode_info()
    local mode_label = mi[1]
    local mode_hl    = mode_to_hl[vim.fn.mode()] or "StMode"

    -- Atualiza a cor do modo dinamicamente
    hl("StMode", c.bg, mi[2], true)
    if mode_to_hl[vim.fn.mode()] then
        hl(mode_to_hl[vim.fn.mode()], c.bg, mi[2], true)
    end

    local filename  = vim.fn.expand("%:t")
    if filename == "" then filename = "[No Name]" end
    local modified  = vim.bo.modified and " ●" or ""
    local readonly  = vim.bo.readonly and " " or ""
    local filetype  = vim.bo.filetype ~= "" and vim.bo.filetype or "plain"
    local encoding  = vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding
    local line      = vim.fn.line(".")
    local col       = vim.fn.col(".")
    local total     = vim.fn.line("$")
    local pct       = math.floor(line / total * 100)

    -- Git branch (sem plugin, usa sistema)
    local branch = ""
    local git = vim.fn.systemlist("git -C " .. vim.fn.expand("%:p:h") .. " rev-parse --abbrev-ref HEAD 2>/dev/null")
    if git and git[1] and git[1] ~= "" then
        branch = "  " .. git[1] .. " "
    end

    local s = ""
    s = s .. "%#" .. (mode_to_hl[vim.fn.mode()] or "StMode") .. "#"
    s = s .. "  " .. mode_label .. "  "
    s = s .. "%#StFile# " .. filename .. modified .. readonly .. " "
    s = s .. "%#StBg#"
    if branch ~= "" then
        s = s .. "%#StGit#" .. branch
    end
    s = s .. "%="   -- Separador central
    s = s .. "%#StInfo# " .. filetype .. "  " .. encoding .. " "
    s = s .. "%#StPos# " .. line .. ":" .. col .. "  " .. pct .. "%% "

    return s
end

setup_hls()

vim.o.statusline = "%!v:lua.Statusline()"
vim.o.laststatus = 2

-- Recria highlights ao trocar de colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = setup_hls,
})
