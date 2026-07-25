#!/usr/bin/env bash
# volume_brightness.sh — Volume control with dunst notifications
# Desktop setup: brightness controls removed (no backlight device)
#
# Usage (i3 config):
#   bindsym XF86AudioRaiseVolume exec ~/.config/i3/scripts/volume_brightness.sh volume_up
#   bindsym XF86AudioLowerVolume exec ~/.config/i3/scripts/volume_brightness.sh volume_down
#   bindsym XF86AudioMute        exec ~/.config/i3/scripts/volume_brightness.sh volume_mute

# ── Config ────────────────────────────────────────────────────────────────────
volume_step=1
max_volume=100
notification_timeout=1000
notification_tag="volume_notif"

# ── Helpers ───────────────────────────────────────────────────────────────────
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

is_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

# Sets $nerd_icon (Nerd Font, shown in notification body)
# and $theme_icon (system theme icon, shown on the left side by dunst)
get_volume_icon() {
    local vol mute
    vol=$(get_volume)
    mute=$(is_muted)
    if [[ "$mute" == "yes" || "$vol" -eq 0 ]]; then
        theme_icon="audio-volume-muted"
    elif [[ "$vol" -lt 50 ]]; then
        theme_icon="audio-volume-low"
    else
        theme_icon="audio-volume-high"
    fi
}

show_volume_notif() {
    local vol
    vol=$(get_volume)
    get_volume_icon
    notify-send \
        -i "$theme_icon" \
        -t "$notification_timeout" \
        -h "string:x-dunst-stack-tag:$notification_tag" \
        -h "int:value:$vol" \
        "Volume" "$vol%"
}

# ── Main ──────────────────────────────────────────────────────────────────────
case "$1" in
volume_up)
    pactl set-sink-mute @DEFAULT_SINK@ 0
    vol=$(get_volume)
    if ((vol + volume_step > max_volume)); then
        pactl set-sink-volume @DEFAULT_SINK@ ${max_volume}%
    else
        pactl set-sink-volume @DEFAULT_SINK@ +${volume_step}%
    fi
    show_volume_notif
    ;;

volume_down)
    pactl set-sink-volume @DEFAULT_SINK@ -${volume_step}%
    show_volume_notif
    ;;

volume_mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_volume_notif
    ;;

*)
    echo "Usage: $(basename "$0") volume_up | volume_down | volume_mute"
    exit 1
    ;;
esac
