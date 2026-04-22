#!/usr/bin/env bash
# calendar.sh — abre o calendário yad posicionado abaixo da barra do Polybar
#
# Requer: yad  →  sudo pacman -S yad

export DISPLAY="${DISPLAY:-:0}"

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax 2>/dev/null)" || true
fi

# Toggle: se já estiver aberto, fecha
if pgrep -x yad >/dev/null 2>&1; then
    pkill -x yad
    exit 0
fi

# Altura da barra (ajuste se necessário)
BAR_HEIGHT=28

# Largura e altura aproximadas do calendário yad
CAL_WIDTH=220
CAL_HEIGHT=180

# Monitor primário DP-2: 1920x1080, offset X=0
# Centraliza o calendário no monitor primário
MONITOR_W=1920
MONITOR_OFFSET_X=0

POS_X=$((MONITOR_OFFSET_X + (MONITOR_W - CAL_WIDTH) / 2))
POS_Y=$BAR_HEIGHT

yad \
    --calendar \
    --undecorated \
    --fixed \
    --no-buttons \
    --title="Calendar" \
    --posx="$POS_X" \
    --posy="$POS_Y" \
    2>/dev/null &

disown
