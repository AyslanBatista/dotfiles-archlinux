# ─── PATH ────────────────────────────────────────────────────
export PATH="$HOME/bin:/usr/local/bin:$PATH:$HOME/.cargo/bin:$HOME/.local/bin"

# ─── CORE ENV ────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
export BROWSER="brave"
export EDITOR=nvim
export VISUAL=nvim
export SUDO_EDITOR=nvim
export ARCHFLAGS="-arch x86_64"
export MANPAGER="nvim +Man!"

# ─── HISTORY ─────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups
setopt hist_save_no_dups
setopt share_history

# ─── ZSH OPTIONS ─────────────────────────────────────────────
setopt autocd               # digitar nome de diretório já entra nele
setopt correct              # sugere correção de comandos digitados errado
setopt interactive_comments # permite # comentários em comandos interativos
setopt no_beep              # sem beep em erros

# ─── COMPLETIONS ─────────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # cores nos completions

# ─── OH MY ZSH ───────────────────────────────────────────────
ZSH_THEME="intheloop"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(
    git
    archlinux
    zsh-autosuggestions
    zsh-syntax-highlighting
    command-not-found
    colored-man-pages
    extract
    z
)

source $ZSH/oh-my-zsh.sh

# ─── AUTOSUGGESTIONS ─────────────────────────────────────────
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ─── FZF ─────────────────────────────────────────────────────
source <(fzf --zsh)

# ─── ALIASES: NAVEGAÇÃO ──────────────────────────────────────
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ─── ALIASES: SISTEMA ────────────────────────────────────────
alias vim='nvim'
alias df='df -h'
alias free='free -h'
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'

# ─── ALIASES: PACMAN ─────────────────────────────────────────
alias pacsearch='pacman -Ss'
alias pacinfo='pacman -Si'
alias pacinstall='sudo pacman -S'
alias pacremove='sudo pacman -Rns'
alias update='sudo pacman -Syu'

# Limpa cache e órfãos com verificação antes de remover
pacclean() {
    sudo pacman -Sc
    local orphans
    orphans=$(pacman -Qtdq 2>/dev/null)
    if [ -n "$orphans" ]; then
        echo "$orphans" | sudo pacman -Rns -
    else
        echo "Nenhum pacote órfão encontrado."
    fi
}

# ─── ALIASES: AUR ────────────────────────────────────────────
alias paruupdate='paru -Syu'
alias paruclean='paru -Sc && paru -c'

# ─── ALIASES: MIRRORS ────────────────────────────────────────
alias update-mirrors='sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak \
  && sudo reflector \
  --country Brazil,US \
  --protocol https \
  --age 24 \
  --latest 20 \
  --sort rate \
  --connection-timeout 5 \
  --download-timeout 5 \
  --threads 5 \
  --save /etc/pacman.d/mirrorlist \
  && sudo pacman -Syy'

# ─── ALIASES: CONFIGS ────────────────────────────────────────
alias i3config='nvim ~/.config/i3/config'
alias picomconfig='nvim ~/.config/picom/picom.conf'
alias polybarconfig='nvim ~/.config/polybar/config.ini'
alias zshrc='nvim ~/.zshrc'
alias code='codium'
alias gdb='pwndbg'

# ─── ALIASES: I3WM ───────────────────────────────────────────
alias i3reload='i3-msg reload'
alias i3restart='i3-msg restart'

# ─── ALIASES: SCRIPTS ────────────────────────────────────────
alias listagem_pacotes='~/.config/i3/scripts/listagem_pacote.sh'
alias scripts='ls ~/.config/i3/scripts/'

# ─── FASTFETCH ───────────────────────────────────────────────
fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
