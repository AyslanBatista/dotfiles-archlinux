#!/usr/bin/env bash
# lock-kiosk.sh — Bloqueio kiosk para i3wm + Polybar
#
# Comportamento:
#   - Abre Chromium em kiosk/fullscreen em cada monitor (threat maps)
#   - Bloqueia input com xtrlock
#   - Ao desbloquear: fecha Chromium, restaura brilho e reinicia Polybar
#
# Dependências: chromium, xtrlock, jq, xrandr, i3-msg
# Coloque em: ~/.config/i3/scripts/lock-kiosk
# Bind no i3 config: bindsym $mod+l exec ~/.config/i3/scripts/lock-kiosk

# -----------------------------------------------------------------------------
# CONFIGURAÇÃO
# -----------------------------------------------------------------------------
URL_LEFT="https://threatmap.checkpoint.com/"
URL_RIGHT="https://livethreatmap.radware.com/"
POLYBAR_LAUNCH="$HOME/.config/polybar/launch.sh"
LOCK_PID_FILE="/tmp/screenlock.pid"
PRIMARY="DP-2"

# -----------------------------------------------------------------------------
# CLEANUP — executado sempre ao sair (desbloqueio, erro, sinal)
# -----------------------------------------------------------------------------
cleanup_lock() {
    rm -f "$LOCK_PID_FILE"

    # Fecha instâncias kiosk abertas por este script
    pkill -f "chromium.*kiosk" 2>/dev/null || true
    pkill -f xtrlock 2>/dev/null || true

    # Sai do modo i3 se estiver em algum
    i3-msg 'mode "default"' >/dev/null 2>&1

    # Restaura brilho em todos os monitores
    while IFS= read -r monitor; do
        xrandr --output "$monitor" --brightness 1.0 2>/dev/null
    done < <(xrandr --listmonitors | tail -n +2 | awk '{print $NF}' | sed 's/^[+*]//')

    # Reinicia Polybar — etapa crítica que estava faltando antes
    if [ -x "$POLYBAR_LAUNCH" ]; then
        bash "$POLYBAR_LAUNCH" >/dev/null 2>&1 &
        echo "Polybar reiniciado."
    else
        echo "AVISO: $POLYBAR_LAUNCH não encontrado ou sem permissão de execução."
    fi

    echo "Sistema desbloqueado."
    exit 0
}

trap cleanup_lock EXIT INT TERM

# -----------------------------------------------------------------------------
# VERIFICAÇÕES INICIAIS
# -----------------------------------------------------------------------------

# Evita bloqueio duplo
if [ -f "$LOCK_PID_FILE" ] && kill -0 "$(cat "$LOCK_PID_FILE")" 2>/dev/null; then
    echo "Bloqueio já está ativo (PID $(cat "$LOCK_PID_FILE"))."
    exit 1
fi

# Checa dependências
for cmd in chromium jq xtrlock xrandr i3-msg; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Erro: '$cmd' não encontrado. Instale antes de continuar."
        exit 1
    fi
done

# Checa número de monitores
mapfile -t MONITORS < <(xrandr --listmonitors | tail -n +2)
if [ "${#MONITORS[@]}" -lt 2 ]; then
    echo "Erro: são necessários 2 ou mais monitores conectados."
    exit 1
fi

# -----------------------------------------------------------------------------
# EFEITO VISUAL DE FLASH
# -----------------------------------------------------------------------------
visual_flash() {
    local monitors=()
    while IFS= read -r m; do
        monitors+=("$m")
    done < <(xrandr --listmonitors | tail -n +2 | awk '{print $NF}' | sed 's/^[+*]//')

    for _ in {1..2}; do
        for m in "${monitors[@]}"; do
            xrandr --output "$m" --brightness 0.3 2>/dev/null
        done
        sleep 0.08
        for m in "${monitors[@]}"; do
            xrandr --output "$m" --brightness 1.0 2>/dev/null
        done
        sleep 0.08
    done
}

# -----------------------------------------------------------------------------
# DETECÇÃO DE WORKSPACES POR MONITOR
# -----------------------------------------------------------------------------

# Extrai os outputs detectados
OUTPUT1=$(echo "${MONITORS[0]}" | awk '{print $NF}' | sed 's/^[+*]//')
OUTPUT2=$(echo "${MONITORS[1]}" | awk '{print $NF}' | sed 's/^[+*]//')

echo "Monitores detectados: $OUTPUT1, $OUTPUT2"
echo "Detectando workspaces por monitor..."

WS_MON1=""
WS_MON2=""

for ws in {1..20}; do
    i3-msg "workspace $ws" >/dev/null 2>&1
    sleep 0.4

    output=$(i3-msg -t get_workspaces | jq -r ".[] | select(.name==\"$ws\") | .output")

    if [ "$output" = "$OUTPUT1" ] && [ -z "$WS_MON1" ]; then
        WS_MON1="$ws"
    elif [ "$output" = "$OUTPUT2" ] && [ -z "$WS_MON2" ]; then
        WS_MON2="$ws"
    fi

    [ -n "$WS_MON1" ] && [ -n "$WS_MON2" ] && break
done

# Fallback: cria workspace dedicado no monitor 2 se nenhum foi encontrado
if [ -z "$WS_MON2" ]; then
    echo "Nenhum workspace encontrado no $OUTPUT2 — forçando workspace 99..."
    i3-msg "workspace 99; move workspace to output $OUTPUT2" >/dev/null 2>&1
    sleep 0.5
    WS_MON2="99"
fi

echo "Workspace para $OUTPUT1: $WS_MON1"
echo "Workspace para $OUTPUT2: $WS_MON2"

# Registra PID do script
echo $$ > "$LOCK_PID_FILE"

# -----------------------------------------------------------------------------
# ABRE CHROMIUM EM KIOSK NOS DOIS MONITORES
# -----------------------------------------------------------------------------
open_chromium() {
    local workspace="$1"
    local url="$2"
    local label="$3"

    i3-msg "workspace $workspace" >/dev/null 2>&1
    sleep 0.5

    chromium \
        --kiosk \
        --app="$url" \
        --disable-infobars \
        --disable-session-crashed-bubble \
        --disable-restore-session-state \
        --disable-features=Translate \
        --noerrdialogs \
        --no-first-run \
        >/dev/null 2>&1 &

    local pid=$!
    sleep 3

    # Garante fullscreen via i3 (o Polybar some automaticamente com fullscreen ativo)
    i3-msg "fullscreen enable" >/dev/null 2>&1

    echo "Chromium aberto em $label — workspace $workspace (PID: $pid)"
}

visual_flash

echo ""
echo "Abrindo navegadores..."
open_chromium "$WS_MON1" "$URL_LEFT"  "$OUTPUT1"
open_chromium "$WS_MON2" "$URL_RIGHT" "$OUTPUT2"

# Foca no monitor primário após abrir os dois
i3-msg "workspace $WS_MON1" >/dev/null 2>&1

# -----------------------------------------------------------------------------
# BLOQUEIO DE INPUT
# -----------------------------------------------------------------------------
echo ""
echo "🔒 BLOQUEIO ATIVO 🔒"
echo "Digite a senha para desbloquear."
echo ""

# xtrlock bloqueia o teclado/mouse até a senha correta do sistema ser digitada.
# Quando ele sai (com sucesso ou falha), o trap EXIT dispara o cleanup_lock,
# que fecha o Chromium e reinicia o Polybar.
xtrlock 2>/dev/null

# Se xtrlock não estiver disponível, fallback manual
if [ $? -ne 0 ]; then
    echo "xtrlock falhou. Aguardando Ctrl+C para desbloquear..."
    while [ -f "$LOCK_PID_FILE" ]; do
        sleep 5
    done
fi
