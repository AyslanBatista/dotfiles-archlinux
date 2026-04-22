# ~/.gdbinit

# ── DebugInfoD ────────────────────────────────────────────────────────────────
set debuginfod enabled on

# ── Display ───────────────────────────────────────────────────────────────────
set show-flags on
set print characters unlimited

# ── Comportamento ─────────────────────────────────────────────────────────────
handle SIGALRM nostop print nopass
set disassembly-flavor intel
