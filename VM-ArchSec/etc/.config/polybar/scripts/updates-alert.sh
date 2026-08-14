#!/bin/bash
THRESHOLD=${1:-${THRESHOLD:-50}}
CACHE="/tmp/polybar-updates-count"

(
    flock 9
    if [[ ! -f "$CACHE" ]] || (($(date +%s) - $(stat -c %Y "$CACHE") >= 540)); then
        checkupdates 2>/dev/null | wc -l >"$CACHE"
    fi
) 9>"$CACHE.lock"

count=$(cat "$CACHE" 2>/dev/null || echo 0)
((count >= THRESHOLD)) && echo "⚠ $count updates" || echo ""
