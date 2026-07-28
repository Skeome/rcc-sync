_rcc_sync_completions()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    opts="help version status diff push pull dry-push dry-pull mirror dry-mirror restore history config init --tui -t -h --help -v --version -q --quiet --verbose -y --yes --json"

    case "${prev}" in
        push|pull)
            COMPREPLY=( $(compgen -W "all file dir" -- ${cur}) )
            return 0
            ;;
        dry-push|dry-pull)
            COMPREPLY=( $(compgen -W "all" -- ${cur}) )
            return 0
            ;;
        mirror|dry-mirror)
            COMPREPLY=( $(compgen -W "local remote" -- ${cur}) )
            return 0
            ;;
        config)
            COMPREPLY=( $(compgen -W "validate" -- ${cur}) )
            return 0
            ;;
        history)
            COMPREPLY=( $(compgen -W "clear" -- ${cur}) )
            return 0
            ;;
        all|local|remote|validate)
            return 0
            ;;
        file|dir|restore)
            compopt -o default
            COMPREPLY=()
            return 0
            ;;
        *)
            ;;
    esac

    if [[ ${COMP_CWORD} == 1 || "${prev}" == -* ]]; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}
complete -F _rcc_sync_completions rcc-sync
