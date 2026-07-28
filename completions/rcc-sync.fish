set -l commands "help version status diff push pull dry-push dry-pull mirror dry-mirror restore history config init"

complete -c rcc-sync -f
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "help" -d "Show help screen"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "version" -d "Show version information"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "status" -d "Show local/remote differences"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "diff" -d "Show detailed differences"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "push" -d "Push local changes to remote"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "pull" -d "Pull remote changes to local"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "dry-push" -d "Preview push"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "dry-pull" -d "Preview pull"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "mirror" -d "DESTRUCTIVE exact sync"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "dry-mirror" -d "Preview mirror"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "restore" -d "Restore from an archived snapshot"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "history" -d "Show or clear the sync history log"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "init" -d "Interactive setup"
complete -c rcc-sync -n "not __fish_seen_subcommand_from $commands" -a "config" -d "Show current configuration"

complete -c rcc-sync -s t -l tui -d "Launch interactive menu-driven mode"
complete -c rcc-sync -s q -l quiet -d "Quiet mode"
complete -c rcc-sync -l verbose -d "Verbose mode"
complete -c rcc-sync -s y -l yes -d "Skip the large-transfer confirmation prompt"
complete -c rcc-sync -l json -d "Machine-readable JSON output (with status)"

# push/pull
complete -c rcc-sync -n "__fish_seen_subcommand_from push pull" -a "all" -d "All files"
complete -c rcc-sync -n "__fish_seen_subcommand_from push pull" -a "file" -d "Specific files"
complete -c rcc-sync -n "__fish_seen_subcommand_from push pull" -a "dir" -d "Specific directory"

# dry-push/dry-pull
complete -c rcc-sync -n "__fish_seen_subcommand_from dry-push dry-pull" -a "all" -d "All files"

# mirror/dry-mirror
complete -c rcc-sync -n "__fish_seen_subcommand_from mirror dry-mirror" -a "local" -d "Local to Remote"
complete -c rcc-sync -n "__fish_seen_subcommand_from mirror dry-mirror" -a "remote" -d "Remote to Local"

# config
complete -c rcc-sync -n "__fish_seen_subcommand_from config" -a "validate" -d "Check configuration for problems"

# history
complete -c rcc-sync -n "__fish_seen_subcommand_from history" -a "clear" -d "Clear the history log"

# File completion for 'file' and 'dir'
complete -c rcc-sync -n "__fish_seen_subcommand_from file dir" -F
