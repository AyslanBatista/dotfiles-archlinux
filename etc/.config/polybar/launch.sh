#!/usr/bin/env bash
# launch.sh — inicia o Polybar no i3wm com suporte a dois monitores
# Monitor primário (DP-2): barra main  — com tray e todos os módulos
# Monitor secundário:      barra secondary — workspaces, data, info básica
#
# Coloque em: ~/.config/polybar/launch.sh
# Chame no ~/.config/i3/config com:
#   exec_always --no-startup-id ~/.config/polybar/launch.sh

PRIMARY="DP-2"

# Encerra instâncias anteriores
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lista todos os monitores conectados
if type "xrandr" > /dev/null 2>&1; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        if [ "$m" = "$PRIMARY" ]; then
            # Monitor primário: barra completa com tray
            MONITOR=$m polybar --reload main 2>&1 | tee -a /tmp/polybar.log & disown
        else
            # Monitor secundário: barra simplificada
            MONITOR=$m polybar --reload secondary 2>&1 | tee -a /tmp/polybar.log & disown
        fi
    done
else
    # Fallback: um monitor só
    polybar --reload main 2>&1 | tee -a /tmp/polybar.log & disown
fi

echo "Polybar iniciado. Primário: $PRIMARY"
