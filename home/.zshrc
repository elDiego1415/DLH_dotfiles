# Created by newuser for 5.9
fastfetch
eval "$(starship init zsh)"

autoload -Uz compinit 
compinit

alias ls='lsd'
alias ll='lsd -la'
alias la='lsd -A'
export LS_COLORS='di=38;5;147:ln=38;5;183:ex=38;5;174:fi=38;5;189:*.sh=38;5;183:*.md=38;5;183:*.txt=38;5;189:*.toml=38;5;147:*.yaml=38;5;147:*.yml=38;5;147:*.json=38;5;147:*.conf=38;5;147:*.ini=38;5;147:*.css=38;5;183:*.js=38;5;187:*.ts=38;5;187:*.py=38;5;151:*.rs=38;5;174:*.png=38;5;219:*.jpg=38;5;219:*.jpeg=38;5;219:*.webp=38;5;219:*.mp3=38;5;183:*.flac=38;5;183:*.mp4=38;5;183:*.mkv=38;5;183:*.zip=38;5;174:*.tar=38;5;174:*.gz=38;5;174'

#plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Comandos válidos → verde
ZSH_HIGHLIGHT_STYLES[command]='fg=green'

# Comandos no encontrados → rojo
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=white'


function yy() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

function ya() {
    yy "$@"
}

function ff() {
    fastfetch "$@"
}

function cmatrix() {
    if [ "$#" -eq 0 ]; then
        printf '\033]4;5;#d6bcfa\033\\'
        command cmatrix -ab -u 5 -C magenta
        local status=$?
        printf '\033]104;5\033\\'
        return "$status"
    else
        command cmatrix "$@"
    fi
}
