# .bashrc

# == Prompt ==
function __precmd_hook {
    # exit code
    __exit_code=$?

    # window title
    echo -ne "\e]0;${PWD/#$HOME/\~}\a"
}

function __status_prompt_module {
    local status=""
    if ! [[ -z "$VIRTUAL_ENV" ]]; then
        status+=" v"
    fi

    if command git rev-parse &> /dev/null; then
        status+=" g"
    fi

    if ! [[ -z "$status" ]]; then
        status+=" "
    fi

    echo "$status"
}

function __char_prompt_module {
    if [[ $__exit_code -eq 0 ]]; then
        echo ' $ '
    else
        echo ' # '
    fi
}

VIRTUAL_ENV_DISABLE_PROMPT="Y"
PROMPT_COMMAND=("__precmd_hook" "${PROMPT_COMMAND[@]}")

PS1='\[\e[48;5;236m\]\[\e[38;5;183m\] \W \[\e[0m\]\
\[\e[48;5;238m\]\[\e[38;5;236m\]\[\e[0m\]\
\[\e[48;5;238m\]\[\e[38;5;242m\]$(__status_prompt_module)\[\e[0m\]\
\[\e[48;5;183m\]\[\e[38;5;238m\]\[\e[0m\]\
\[\e[48;5;183m\]\[\e[38;5;189m\]$(__char_prompt_module)\[\e[0m\]\
\[\e[38;5;183m\]\[\e[0m\] '

#general

alias v="nvim"
alias update="sudo apt update && sudo apt upgrade"
alias size="du -sh"
alias neofetch="fastfetch"
alias uptime="uptime -p"
alias ipp="curl -s ipinfo.io/ip | awk '{print $1}'"
alias info="sudo dmidecode | grep -A 9 'System Information'"
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

#sysinfo

alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'

# functions

num() {
    local dir=${1:-.}  # Default to current directory if no argument is provided
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

export SUDO_EDITOR=nvim
