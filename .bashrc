# .bashrc

#promt
PS1="\[\e[1m\]\[\e[31m\][\[\e[33m\]\u\[\e[32m\]@\[\e[34m\]\h \[\e[35m\]\w\[\e[31m\]]\[\e[0m\]$ "

#general
alias v="nvim"
alias update="sudo apt update && sudo apt upgrade"
alias size="du -sh"
alias neofetch="fastfetch"
alias uptime="uptime -p"
alias ipp="curl -s ipinfo.io/ip | awk '{print $1}'"
alias cls="clear"
alias mkdir='mkdir -pv'
alias ls="eza"
alias ll="eza -l"
alias la="eza -la"
alias l="eza -l"
alias linutil="curl -fsSL https://christitus.com/linux | sh"
alias f="sudo find . | grep "
alias countfiles="for t in files links directories; do echo \`find . -type \${t:0:1} | wc -l\` \$t; done 2> /dev/null"

#networking
alias openports='netstat -nape --inet'
alias ws="sudo tshark"

#sysinfo
alias meminfo='sudo dmidecode --type=memory'
alias sysinfo='sudo dmidecode --type=chassis'
alias biosinfo='sudo dmidecode --types=bios'
alias cpuinfo='lscpu'


#functions

num() {
    local dir=${1:-.}
    sudo find "$dir" -type f | wc -l
}

function up {
    local limit=$1
    local d=""

    for ((i=0; i<limit; i++)); do
        d="$d/.."
    done

    d=$(echo "$d" | sed 's/^\///')

    if [[ -z "$d" ]]; then
        d=".."
    fi

    cd "$d"
}

#variables
export SUDO_EDITOR=nvim
export EDITOR=nvim

#extra
pokemon-colorscripts -r --no-title 
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
