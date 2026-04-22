#!/usr/bin/env bash
# calendar.sh — popup de calendário para Polybar + i3wm
#
# Dependências: yad, xdotool
#   sudo pacman -S yad xdotool
#
# i3wm config (~/.config/i3/config) — adicione esta linha:
#   for_window [class="Yad" title="yad-calendar"] floating enable, border none
#
# Polybar module:
#   [module/date]
#   type     = custom/script
#   exec     = date "+%A %d %b %H:%M:%S"
#   interval = 1
#   click-left = ~/.config/polybar/scripts/calendar.sh &

export DISPLAY="${DISPLAY:-:0}"

# Garante que o D-Bus esteja disponível (necessário para yad em alguns setups)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval "$(dbus-launch --sh-syntax 2>/dev/null)" || true
fi

# --- Configurações ---
BAR_HEIGHT=28  # Altura do Polybar em pixels
CAL_WIDTH=222  # Largura do calendário yad
CAL_HEIGHT=188 # Altura do calendário yad
BORDER_SIZE=2  # Margem entre a barra e o calendário

# Toggle: se já estiver aberto, fecha
if pgrep -x yad >/dev/null 2>&1; then
    pkill -x yad
    exit 0
fi

# Captura a posição atual do cursor (onde o usuário clicou no Polybar)
# xdotool exporta as variáveis X, Y, SCREEN, WINDOW no shell atual
eval "$(xdotool getmouselocation --shell)"

# Detecta as dimensões da tela onde o cursor está
# xrandr lista todos os monitores com resolução e offset; grep filtra o monitor ativo
SCREEN_INFO=$(xrandr --query | grep " connected" | awk '
    /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {
        match($0, /([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+)/, arr)
        print arr[1], arr[2], arr[3], arr[4]
    }
')

# Itera sobre os monitores para encontrar qual contém o cursor (X, Y)
SCREEN_W=1920
SCREEN_H=1080
SCREEN_X=0
SCREEN_Y=0

while read -r sw sh sx sy; do
    # Verifica se o cursor está dentro dos limites desse monitor
    if [ "$X" -ge "$sx" ] && [ "$X" -lt "$((sx + sw))" ] &&
        [ "$Y" -ge "$sy" ] && [ "$Y" -lt "$((sy + sh))" ]; then
        SCREEN_W=$sw
        SCREEN_H=$sh
        SCREEN_X=$sx
        SCREEN_Y=$sy
        break
    fi
done <<<"$SCREEN_INFO"

# Calcula POS_X: centraliza o calendário sob o cursor, mas sem sair da tela
POS_X=$((X - CAL_WIDTH / 2))

# Clamp horizontal: garante que não ultrapasse as bordas do monitor
if [ "$POS_X" -lt "$SCREEN_X" ]; then
    POS_X=$SCREEN_X
fi
if [ "$((POS_X + CAL_WIDTH))" -gt "$((SCREEN_X + SCREEN_W))" ]; then
    POS_X=$((SCREEN_X + SCREEN_W - CAL_WIDTH))
fi

# Calcula POS_Y: Polybar no topo → calendário abre abaixo da barra
# Se a barra estiver no fundo (Y próximo ao final da tela), abre acima do cursor
if [ "$Y" -lt "$((SCREEN_H / 2))" ]; then
    # Barra no topo
    POS_Y=$((BAR_HEIGHT + BORDER_SIZE))
else
    # Barra no fundo
    POS_Y=$((Y - CAL_HEIGHT - BORDER_SIZE))
fi

yad \
    --calendar \
    --undecorated \
    --fixed \
    --no-buttons \
    --title="yad-calendar" \
    --posx="$POS_X" \
    --posy="$POS_Y" \
    --width="$CAL_WIDTH" \
    --height="$CAL_HEIGHT" \
    2>/dev/null &

disown
