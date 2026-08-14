#!/bin/bash
GREEN="#a6e3a1"
GRAY="#6c7086"
RED="#f38ba8"

VPN_IFACE=$(ip -o link show up 2>/dev/null | awk -F': ' '/tun|tap|wg/ {print $2}' | head -n1)

if [ -n "$VPN_IFACE" ]; then
    IP=$(ip -4 addr show "$VPN_IFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    if [ -n "$IP" ]; then
        echo "%{F$GREEN}%{F-}%{F$GREEN}$IP%{F-}"
    else
        echo "%{F$RED}%{F-}VPN sem IP"
    fi
else
    IFACE=$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')
    IP=$(ip -4 addr show "$IFACE" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "%{F$GRAY}%{F-}%{F$GRAY}${IP:-N/A}%{F-}"
fi
