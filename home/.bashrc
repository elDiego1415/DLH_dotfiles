#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='lsd'
alias ll='lsd -la'
alias la='lsd -A'
export LS_COLORS='di=38;5;147:ln=38;5;183:ex=38;5;174:fi=38;5;189:*.sh=38;5;183:*.md=38;5;183:*.txt=38;5;189:*.toml=38;5;147:*.yaml=38;5;147:*.yml=38;5;147:*.json=38;5;147:*.conf=38;5;147:*.ini=38;5;147:*.css=38;5;183:*.js=38;5;187:*.ts=38;5;187:*.py=38;5;151:*.rs=38;5;174:*.png=38;5;219:*.jpg=38;5;219:*.jpeg=38;5;219:*.webp=38;5;219:*.mp3=38;5;183:*.flac=38;5;183:*.mp4=38;5;183:*.mkv=38;5;183:*.zip=38;5;174:*.tar=38;5;174:*.gz=38;5;174'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
