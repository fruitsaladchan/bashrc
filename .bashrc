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
PS1='\[\e[48;2;192;163;110m\]\[\e[38;2;31;31;40m\] \W \[\e[0m\]\
\[\e[48;2;54;54;70m\]\[\e[38;2;192;163;110m\]\[\e[0m\]\
\[\e[48;2;54;54;70m\]\[\e[38;2;184;180;208m\]$(__status_prompt_module)\[\e[0m\]\
\[\e[48;2;149;127;184m\]\[\e[38;2;54;54;70m\]\[\e[0m\]\
\[\e[48;2;149;127;184m\]\[\e[38;2;31;31;40m\]$(__char_prompt_module)\[\e[0m\]\
\[\e[38;2;149;127;184m\]\[\e[0m\] '

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

#networking

alias dnstop='dnstop -l 5  eno2'
alias vnstat='vnstat -i eno2'
alias iftop='iftop -i eno2'
alias tcpdump='tcpdump -i eno2'
alias ethtool='ethtool eno2'

#sysinfo

alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4 | head -10'
alias pscpu='ps auxf | sort -nr -k 3 | head -10'
alias cpuinfo='lscpu'
