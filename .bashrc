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
# Change colors here
PS1='\[\e[48;5;240m\]\[\e[38;5;255m\] \W \[\e[0m\]\
\[\e[48;5;236m\]\[\e[38;5;240m\]\[\e[0m\]\
\[\e[48;5;236m\]\[\e[38;5;250m\]$(__status_prompt_module)\[\e[0m\]\
\[\e[48;5;31m\]\[\e[38;5;236m\]\[\e[0m\]\
\[\e[48;5;31m\]\[\e[38;5;255m\]$(__char_prompt_module)\[\e[0m\]\
\[\e[38;5;31m\]\[\e[0m\] '

#general

alias v="nvim"
alias update="sudo apt update && sudo apt upgrade"
alias size="du -sh"
alias num="find . -type f | wc -l"
alias uptime="uptime -p"
alias ipp="curl -s ipinfo.io/ip | awk '{print $1}'"
alias info="sudo dmidecode | grep -A 9 'System Information'"
alias mkdir='mkdir -pv'
alias ports='netstat -tulanp'
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

# disk space

alias diskspace="du -S | sort -n -r |more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias tree='tree -CAhF --dirsfirst'
alias treed='tree -CAFd'
alias mountedinfo='df -hT'
