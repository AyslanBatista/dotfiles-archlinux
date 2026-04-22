#!/bin/bash

THRESHOLD=${THRESHOLD:-50}

count=$(checkupdates 2>/dev/null | wc -l)

if [ "$count" -ge "$THRESHOLD" ]; then
    echo "⚠ $count updates"
else
    echo ""
fi
