#!/usr/bin/env bash
# ============================================================
#  rofi-beats — i3wm + Audacious + dunst/Qogir
#  Original: https://github.com/JaKooLit
#  Adaptado por: ayslan
# ============================================================
#
# Dependências: rofi, audacious, dunst, yt-dlp, notify-send
#
# ============================================================

# --------------- Modo estrito -------------------------------
# -e  → sai imediatamente se qualquer comando falhar
# -u  → trata variáveis não definidas como erro
# -o pipefail → falha em pipelines se qualquer comando falhar
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
# mktemp garante nome único e imprevisível (mitigação de symlink attack)
# O arquivo é criado uma vez e reutilizado entre execuções do script
# via convenção de nome fixo — mas dentro de um diretório por sessão
YT_DAEMON_PID="${XDG_RUNTIME_DIR:-/tmp}/rofi-beats-yt-${UID}.pid"

# ============================================================
#  ESTAÇÕES ONLINE
#  - URLs do YouTube    → yt-dlp progressivo em background
#  - URLs de rádio HTTP → enviadas diretamente ao Audacious
# ============================================================
declare -A online_music=(
    ["YT - Instrumental BASS 😎🎶"]="https://youtube.com/playlist?list=PL9q0n3HNppU2S2V3K6JUCoewvnQ5D6Uag&si=Od8Iq1G3saNjqTFm"
    ["YT - Instrumental Louvor 🎻🎼"]="https://youtube.com/playlist?list=PL9q0n3HNppU0EcqSzwHV12pHMNb0fs9Ze&si=vCHA54-TZv1fnkNE"
    ["YT - Programming Music 🎧🎶"]="https://www.youtube.com/playlist?list=PLdnVyoeE0BGnv9XY8vEXwboZWWfNQEt2V"
    ["YT - lofi hip hop radio beats 📹🎶"]="https://www.youtube.com/live/jfKfPfyJRdk?si=PnJIA9ErQIAw6-qd"
    ["Radio - Lofi Girl 🎧🎶"]="https://play.streamafrica.net/lofiradio"
    ["Radio - Chillhop 🎧🎶"]="http://stream.zeno.fm/fyn8eh3h5f8uv"
    ["Radio - Ibiza Global 🎧🎶"]="https://cdn-peer031.streaming-pro.com:8025/ibizaglobalradio.mp3"
)

# ============================================================
#  FUNÇÕES AUXILIARES
# ============================================================

notification() {
    local urgency="$1"
    local title="$2"
    local body="$3"
    local icon="$4"
    notify-send -u "$urgency" -i "$icon" "$title" "$body"
}

is_youtube_url() {
    [[ "$1" == *"youtube.com"* || "$1" == *"youtu.be"* ]]
}

# Mata o daemon de extração YT anterior, se existir
kill_yt_daemon() {
    if [[ -f "$YT_DAEMON_PID" ]]; then
        local old_pid
        old_pid=$(cat "$YT_DAEMON_PID")
        # Valida que o conteúdo do arquivo é realmente um número (PID)
        # antes de tentar matar — evita execução acidental de conteúdo malicioso
        if [[ "$old_pid" =~ ^[0-9]+$ ]]; then
            # Tenta matar o grupo de processos inteiro (daemon + filhos yt-dlp)
            kill -- -"$old_pid" 2>/dev/null || kill "$old_pid" 2>/dev/null || true
        fi
        rm -f "$YT_DAEMON_PID"
    fi
}

# ============================================================
#  DAEMON DE EXTRAÇÃO PROGRESSIVA DO YOUTUBE
#
#  Exportado como função para ser chamado via subshell sem
#  interpolação de string (mais seguro que bash -c "$(declare -f ...)")
#
#  Fluxo:
#  1. Coleta IDs de vídeo via --flat-playlist (sem baixar nada)
#  2. Embaralha com shuf
#  3. Para cada ID: extrai stream com yt-dlp -g e enfileira no Audacious
#     O delay entre extrações é delegado ao próprio yt-dlp via
#     --sleep-requests, que é aplicado no momento correto do ciclo
# ============================================================
yt_progressive_daemon() {
    local url="$1"
    local ico_music="$2"
    local ico_warn="$3"

    # Coleta apenas os IDs sem resolver cada vídeo individualmente
    # --no-warnings: suprime avisos de vídeos privados/indisponíveis
    # --ignore-errors: continua mesmo se alguns vídeos falharem
    local -a video_ids
    mapfile -t video_ids < <(
        yt-dlp \
            --flat-playlist \
            --print id \
            --no-warnings \
            --ignore-errors \
            "$url" 2>/dev/null
    )

    if [[ ${#video_ids[@]} -eq 0 ]]; then
        notify-send -u critical -i "$ico_warn" \
            "⚠ Erro" "Não foi possível listar a playlist.\nVerifique sua conexão."
        exit 1
    fi

    # Embaralha os IDs antes de iniciar a extração
    mapfile -t video_ids < <(printf "%s\n" "${video_ids[@]}" | shuf)

    local first=true

    for vid_id in "${video_ids[@]}"; do
        local yt_url="https://www.youtube.com/watch?v=${vid_id}"

        # Extrai a URL direta do stream de áudio
        # --retries 3: tenta até 3 vezes em caso de falha transitória
        # --sleep-requests 2: delay de 2s entre requisições HTTP internas
        #   (delegado ao yt-dlp em vez de sleep manual — mais preciso)
        # --no-warnings: suprime logs de vídeos indisponíveis
        local stream_url
        stream_url=$(
            yt-dlp \
                -g \
                --format "bestaudio/best" \
                --retries 3 \
                --sleep-requests 2 \
                --no-warnings \
                "$yt_url" 2>/dev/null | head -1
        ) || true # não deixa set -e matar o daemon se um vídeo falhar

        # Pula vídeos indisponíveis (privados, removidos, etc.)
        [[ -z "$stream_url" ]] && continue

        if $first; then
            # Primeira faixa: abre playlist temporária no Audacious
            audacious -E "$stream_url"
            first=false
        else
            # Faixas seguintes: enfileira no final da playlist atual
            audacious -e "$stream_url"
        fi
    done
}

# Exporta a função para que o subshell criado pelo setsid possa acessá-la
export -f yt_progressive_daemon

# ============================================================
#  FUNÇÃO PRINCIPAL DE REPRODUÇÃO ONLINE
# ============================================================

play_url() {
    local label="$1"
    local url="$2"

    # Encerra extração anterior antes de iniciar nova
    kill_yt_daemon

    if is_youtube_url "$url"; then
        notification "normal" "⏳ Carregando..." \
            "Iniciando playlist:\n$label" "$ICO_MUSIC"

        # setsid cria novo grupo de processos para o daemon
        # Isso permite encerrar o daemon e todos seus filhos (yt-dlp)
        # com um único kill -- -PID sem afetar o processo principal
        # export -f garante que yt_progressive_daemon esteja disponível
        # no subshell sem interpolação de string insegura
        setsid bash -c "yt_progressive_daemon \"\$1\" \"\$2\" \"\$3\"" \
            -- "$url" "$ICO_MUSIC" "$ICO_WARN" &

        # Salva o PID do grupo para controle futuro
        echo $! >"$YT_DAEMON_PID"

        notification "normal" "🎵 Now Playing" "$label" "$ICO_MUSIC"

    else
        # Rádio HTTP — Audacious resolve nativamente sem yt-dlp
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

# Fecha rofi se já estiver aberto (toggle behavior)
if pidof rofi >/dev/null; then
    pkill rofi
    exit 0
fi

populate_playlists

menu_items=()

# Stop Music — apenas se o Audacious estiver rodando
if pgrep -x audacious >/dev/null; then
    menu_items+=("⏹ Stop Music")
fi

# Playlists locais com prefixo 📋
for name in "${playlist_names[@]}"; do
    menu_items+=("📋 $name")
done

# Estações online ordenadas com prefixo 📻
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
    pkill -x audacious
    notification "low" "⏹ Música parada" "Audacious encerrado." "$ICO_STOP"
    exit 0
fi

# Playlist local (prefixo 📋)
if [[ "$choice" == "📋"* ]]; then
    playlist_label=$(echo "$choice" | sed 's/^📋 //')
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

# Estação online (prefixo 📻)
if [[ "$choice" == "📻"* ]]; then
    station_label=$(echo "$choice" | sed 's/^📻 //')
    station_url="${online_music[$station_label]}"

    if [[ -z "$station_url" ]]; then
        notification "critical" "⚠ Erro" \
            "URL não encontrada para:\n$station_label" "$ICO_WARN"
        exit 1
    fi

    play_url "$station_label" "$station_url"
    exit 0
fi
