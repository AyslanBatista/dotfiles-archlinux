#!/usr/bin/env bash
# launch.sh — inicia o Polybar no i3wm (monitor único)
# VM 01-Arch-Sec — sem segundo monitor
#
# Coloque em: ~/.config/polybar/launch.sh
# Chame no ~/.config/i3/config com:
#   exec_always --no-startup-id ~/.config/polybar/launch.sh

# Encerra instâncias anteriores
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Monitor único — polybar detecta automaticamente
polybar --reload main 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar iniciado."
