#!/usr/bin/env bash
# ============================================================
#  rofi-beats — i3wm + Audacious + dunst/Qogir
# ============================================================
#
# Dependências: rofi, audacious, dunst, yt-dlp, notify-send
#
# IMPORTANTE — dotfiles no GitHub:
#   Adicione ao seu .gitignore:
#     .config/audacious/playlists/
#     .config/audacious/config
#   As CDN URLs do YouTube (googlevideo.com) contêm seu IP público
#   embutido como parâmetro e são salvas automaticamente pelo Audacious.
#
# ============================================================

# --------------- Modo estrito -------------------------------
set -euo pipefail

# --------------- Diretórios ---------------------------------
playlistDIR="${HOME}/Music/"

# --------------- Tema rofi ----------------------------------
rofi_theme="${HOME}/.config/rofi/config.rasi"

# --------------- Ícones (Qogir) -----------------------------
ICO_MUSIC="/usr/share/icons/Qogir/scalable/apps/audacious.svg"
ICO_STOP="/usr/share/icons/Qogir/16/actions/process-stop.svg"
ICO_WARN="/usr/share/icons/Qogir/16/actions/dialog-warning.svg"

# --------------- Arquivo de PID do daemon YT ----------------
YT_DAEMON_PID="${XDG_RUNTIME_DIR:-/tmp}/rofi-beats-yt-${UID}.pid"

# --------------- Playlists do Audacious ---------------------
AUDACIOUS_PLAYLISTS="${HOME}/.config/audacious/playlists"

# ============================================================
#  ESTAÇÕES ONLINE
#  - URLs do YouTube    → yt-dlp progressivo em background
#  - URLs de rádio HTTP → enviadas diretamente ao Audacious
#
#  Nota: prefira HTTPS nas URLs de rádio onde disponível.
# ============================================================
declare -A online_music=(
    ["YT - Instrumental BASS 😎🎶"]="https://youtube.com/playlist?list=PL9q0n3HNppU2S2V3K6JUCoewvnQ5D6Uag&si=Od8Iq1G3saNjqTFm"
    ["YT - Instrumental Louvor 🎻🎼"]="https://youtube.com/playlist?list=PL9q0n3HNppU0EcqSzwHV12pHMNb0fs9Ze&si=vCHA54-TZv1fnkNE"
    ["YT - Programming Music 🎧🎶"]="https://www.youtube.com/playlist?list=PLdnVyoeE0BGnv9XY8vEXwboZWWfNQEt2V"
    ["YT - lofi hip hop radio beats 📹🎶"]="https://www.youtube.com/live/jfKfPfyJRdk?si=PnJIA9ErQIAw6-qd"
    ["Radio - Lofi Girl 🎧🎶"]="https://play.streamafrica.net/lofiradio"
    ["Radio - Chillhop 🎧🎶"]="https://stream.zeno.fm/fyn8eh3h5f8uv"
    ["Radio - Ibiza Global 🎧🎶"]="https://cdn-peer031.streaming-pro.com:8025/ibizaglobalradio.mp3"
)

# ============================================================
#  FUNÇÕES AUXILIARES
# ============================================================

notification() {
    local urgency="$1" title="$2" body="$3" icon="$4"
    notify-send -u "$urgency" -i "$icon" "$title" "$body"
}

is_youtube_url() {
    [[ "$1" == *"youtube.com"* || "$1" == *"youtu.be"* ]]
}

# Remove as playlists salvas pelo Audacious.
# As CDN URLs do YouTube contêm o IP público no parâmetro &ip=.
# Chamado sempre ao encerrar o Audacious para não acumular esse dado.
clear_audacious_playlists() {
    rm -f "${AUDACIOUS_PLAYLISTS}"/*.audpl 2>/dev/null || true
}

# Mata o daemon de extração YT anterior, se existir.
kill_yt_daemon() {
    [[ -f "$YT_DAEMON_PID" ]] || return 0

    local old_pid
    # $(< arquivo) usa builtin do bash — evita fork desnecessário de cat
    old_pid=$(<"$YT_DAEMON_PID")

    # Valida que o conteúdo é um PID numérico e que o processo ainda existe.
    # kill -0 verifica existência sem enviar sinal real — evita matar
    # um PID que foi reutilizado pelo kernel após o daemon terminar.
    if [[ "$old_pid" =~ ^[0-9]+$ ]] && kill -0 "$old_pid" 2>/dev/null; then
        # Mata o grupo de processos inteiro (daemon + filhos yt-dlp)
        kill -- -"$old_pid" 2>/dev/null || kill "$old_pid" 2>/dev/null || true
    fi

    rm -f "$YT_DAEMON_PID"
}

# ============================================================
#  DAEMON DE EXTRAÇÃO PROGRESSIVA DO YOUTUBE
# ============================================================
yt_progressive_daemon() {
    local url="$1"
    local ico_music="$2"
    local ico_warn="$3"

    local -a video_ids
    mapfile -t video_ids < <(
        yt-dlp \
            --flat-playlist \
            --print id \
            --no-warnings \
            --ignore-errors \
            "$url" 2>/dev/null |
            shuf
    )

    if [[ ${#video_ids[@]} -eq 0 ]]; then
        notify-send -u critical -i "$ico_warn" \
            "⚠ Erro" "Não foi possível listar a playlist.\nVerifique sua conexão."
        exit 1
    fi

    local first=true

    for vid_id in "${video_ids[@]}"; do
        if ! pgrep -x audacious >/dev/null && ! $first; then
            break
        fi

        local yt_url="https://www.youtube.com/watch?v=${vid_id}"

        local stream_url
        stream_url=$(
            yt-dlp \
                -g \
                --format "bestaudio/best" \
                --retries 3 \
                --no-warnings \
                "$yt_url" 2>/dev/null
        ) || true

        [[ -z "$stream_url" ]] && continue

        if $first; then
            audacious -E "$stream_url"
            first=false
        else
            audacious -e "$stream_url"
        fi
    done
}

export -f yt_progressive_daemon

# ============================================================
#  FUNÇÃO PRINCIPAL DE REPRODUÇÃO ONLINE
# ============================================================

play_url() {
    local label="$1"
    local url="$2"

    kill_yt_daemon

    if is_youtube_url "$url"; then
        notification "normal" "⏳ Carregando..." \
            "Iniciando playlist:\n$label" "$ICO_MUSIC"

        setsid bash -c "yt_progressive_daemon \"\$1\" \"\$2\" \"\$3\"" \
            -- "$url" "$ICO_MUSIC" "$ICO_WARN" &

        echo $! >"$YT_DAEMON_PID"

        notification "normal" "🎵 Now Playing" "$label" "$ICO_MUSIC"
    else
        audacious -E "$url" &
        notification "normal" "🎵 Now Playing" "$label" "$ICO_MUSIC"
    fi
}

# ============================================================
#  PLAYLISTS .M3U LOCAIS
# ============================================================

populate_playlists() {
    playlists=()
    playlist_names=()
    mkdir -p "$playlistDIR"
    while IFS= read -r file; do
        playlists+=("$file")
        playlist_names+=("$(basename "${file%.*}")")
    done < <(find -L "$playlistDIR" -type f \( -iname "*.m3u" -o -iname "*.m3u8" \) | sort)
}

# ============================================================
#  MENU PRINCIPAL UNIFICADO
# ============================================================

if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

populate_playlists

menu_items=()

if pgrep -x audacious >/dev/null; then
    menu_items+=("⏹ Stop Music")
fi

for name in "${playlist_names[@]}"; do
    menu_items+=("📋 $name")
done

while IFS= read -r station; do
    menu_items+=("📻 $station")
done < <(printf "%s\n" "${!online_music[@]}" | sort)

choice=$(printf "%s\n" "${menu_items[@]}" | rofi -i -dmenu -config "$rofi_theme" -p "🎵 Beats")

[[ -z "$choice" ]] && exit 0

# ============================================================
#  ROTEAMENTO
# ============================================================

if [[ "$choice" == "⏹ Stop Music" ]]; then
    kill_yt_daemon
    audacious --stop
    sleep 0.3
    pkill -x audacious 2>/dev/null || true
    clear_audacious_playlists
    notification "low" "⏹ Música parada" "Audacious encerrado." "$ICO_STOP"
    exit 0
fi

# Playlist local — usa expansão de parâmetro do bash no lugar de sed+fork
if [[ "$choice" == "📋"* ]]; then
    playlist_label="${choice#"📋 "}"
    for ((i = 0; i < ${#playlist_names[@]}; i++)); do
        if [[ "${playlist_names[$i]}" == "$playlist_label" ]]; then
            kill_yt_daemon
            notification "normal" "📋 Playlist" \
                "Reproduzindo: $playlist_label" "$ICO_MUSIC"
            audacious -E "${playlists[$i]}" &
            exit 0
        fi
    done
    notification "critical" "⚠ Erro" \
        "Playlist não encontrada:\n$playlist_label" "$ICO_WARN"
    exit 1
fi

# Estação online — usa expansão de parâmetro do bash no lugar de sed+fork
if [[ "$choice" == "📻"* ]]; then
    station_label="${choice#"📻 "}"
    station_url="${online_music[$station_label]}"

    if [[ -z "$station_url" ]]; then
        notification "critical" "⚠ Erro" \
            "URL não encontrada para:\n$station_label" "$ICO_WARN"
        exit 1
    fi

    play_url "$station_label" "$station_url"
    exit 0
fi
