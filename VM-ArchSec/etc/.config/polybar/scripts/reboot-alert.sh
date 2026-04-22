#!/bin/bash

REBOOT_PKGS="linux linux-firmware amd-ucode intel-ucode systemd glibc"

boot_time=$(uptime -s)

for pkg in $REBOOT_PKGS; do
    if LC_ALL=C pacman -Q "$pkg" &>/dev/null; then
        pkg_date=$(LC_ALL=C pacman -Qi "$pkg" | grep "Install Date" | sed 's/Install Date\s*:\s*//')
        pkg_time=$(date -d "$pkg_date" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)
        if [[ "$pkg_time" > "$boot_time" ]]; then
            notify-send -u critical "󰜉  Reboot required" "Critical package updated: $pkg"
            exit 0
        fi
    fi
done
