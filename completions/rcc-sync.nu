export extern rcc-sync [
  --tui(-t)       # Launch interactive menu-driven mode
  --quiet(-q)     # Quiet mode
  --verbose       # Verbose mode
  --help(-h)      # Show help
  --version(-v)   # Show version
]

export extern "rcc-sync status" []
export extern "rcc-sync diff" []
export extern "rcc-sync config" []
export extern "rcc-sync init" []
export extern "rcc-sync push all" []
export extern "rcc-sync push file" [...files: path]
export extern "rcc-sync push dir" [directory: directory]
export extern "rcc-sync pull all" []
export extern "rcc-sync pull file" [...files: path]
export extern "rcc-sync pull dir" [directory: directory]
export extern "rcc-sync dry-push all" []
export extern "rcc-sync dry-pull all" []
export extern "rcc-sync mirror local" []
export extern "rcc-sync mirror remote" []
export extern "rcc-sync dry-mirror local" []
export extern "rcc-sync dry-mirror remote" []
