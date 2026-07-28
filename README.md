# RCC Sync

> Work locally. Sync intentionally.

RCC Sync is a safe, explicit synchronization utility for Linux.

Built on top of `rsync`, RCC Sync provides a simple command-line and terminal user interface for synchronizing files between any two filesystem-accessible locations while keeping the user in control of when changes occur.

Unlike traditional synchronization tools, RCC Sync never runs in the background, never communicates with the network itself, and never performs automatic file transfers. Every operation is explicitly initiated by the user.

Common destinations include:

- OneDrive-backed directories
- External drives
- NAS storage
- Archive directories
- Secondary disks
- Cloud-mounted filesystems
- Cross-device synchronization targets

RCC Sync was originally developed for Linux users at Rogue Community College as a controlled alternative to traditional cloud synchronization workflows, but it has since evolved into a general-purpose synchronization tool.

Typical workflows include:

```text
Laptop
    ↑
    │ rcc-sync
    ↓
External Drive
```

```text
Local Workspace
    ↑
    │ rcc-sync
    ↓
NAS Storage
```

```text
~/College
    ↑
    │ rcc-sync
    ↓
~/OneDrive/College
    ↑
    │ OneDrive Client
    ↓
Microsoft OneDrive
```

---

## Why RCC Sync?

Most traditional synchronization tools are designed around automation:

```text
Edit File
    ↓
Automatic Synchronization
    ↓
Remote Storage
```

While convenient, this approach can make it difficult to:

- Review changes before they are transferred
- Control when files are uploaded
- Organize projects without triggering immediate synchronization
- Maintain intentional workflows similar to version control

RCC Sync takes a different approach:

```text
Edit File
    ↓
Review Changes
    ↓
Preview Synchronization
    ↓
Manual Push / Pull / Mirror
    ↓
Destination
```

The result is a workflow that emphasizes visibility, control, and safety rather than automation.
For users familiar with Git, RCC Sync often feels more like a publish-and-sync workflow than a traditional cloud client.

---

This workflow is particularly useful for:

- Students
- Linux users
- Version-control minded users
- Users who prefer explicit synchronization
- Users who want to avoid accidental cloud updates

RCC Sync was originally developed for Linux users at Rogue Community College but is useful anywhere Linux needs intentional file synchronization.

---

## Common Use Cases

- OneDrive synchronization
- External drive backups
- NAS synchronization
- Course material management
- Archive replication
- Cross-device file transfer

---

## Features

### Safe by Default

RCC Sync push/pull operations:

✅ Never delete files

✅ Never sync automatically

✅ Never talk to the network themselves

✅ Require explicit user actions

✅ Support dry-run previews

✅ Refuse `push file`/`pull file`/`push dir`/`pull dir` paths that resolve (via `../` or a symlink) outside LOCAL_ROOT/REMOTE_ROOT

✅ Warn and ask for confirmation before unusually large transfers

> [!NOTE]
> The `mirror` command intentionally uses `rsync --delete` and **will** delete files in the target directory. A backup snapshot is always created automatically before any mirror operation, and can be restored with `rcc-sync restore`. See [Mirror Operations](#mirror-operations) and [Snapshots & Restore](#snapshots--restore) below.

---

### Configuration Support

Configure any directory layout:

```bash
rcc-sync init
```

Configuration is stored in:

```text
~/.config/rcc-sync/config
```

Example:

```text
LOCAL_ROOT=~/College
REMOTE_ROOT=~/OneDrive/College
ARCHIVE_DIR=~/.rcc-sync-archives

EXCLUDE_FILE=
EXCLUDE_PATTERNS=

CONFIRM_FILE_THRESHOLD=100
CONFIRM_SIZE_THRESHOLD_MB=500
```

| Key | Default | Description |
| --- | --- | --- |
| `LOCAL_ROOT` | `~/College` | Your local working directory |
| `REMOTE_ROOT` | `~/OneDrive/College` | OneDrive-backed mirror directory |
| `ARCHIVE_DIR` | `~/.rcc-sync-archives` | Where pre-mirror/pre-restore backup snapshots are saved |
| `EXCLUDE_FILE` | *(none)* | Path to a file of rsync-style exclude patterns, one per line |
| `EXCLUDE_PATTERNS` | *(none)* | Comma-separated inline exclude patterns, e.g. `*.tmp,node_modules` |
| `CONFIRM_FILE_THRESHOLD` | `100` | Prompt before transferring at least this many files (`0` disables) |
| `CONFIRM_SIZE_THRESHOLD_MB` | `500` | Prompt before transferring at least this much data (`0` disables) |

> [!TIP]
> Set `ARCHIVE_DIR=~/OneDrive/RCC-Sync_Archives` to have your backup snapshots automatically uploaded to the cloud by your OneDrive client.

Check your configuration for common problems (missing directories, nested roots, an unwritable archive dir, and so on) with:

```bash
rcc-sync config validate
```

`rcc-sync config` also shows your most recent sync at a glance.

---

### Status Reporting

```bash
rcc-sync status
```

Example output:

<img width="1854" height="969" alt="Status" src="https://github.com/user-attachments/assets/7f0549a9-836b-4629-a1f7-4d524938fd7e" />

```text
Last sync: push all — 2026-07-26 14:32:10

LOCAL ONLY

  CIS120/lab3.pdf

REMOTE ONLY

  MTH111Z/syllabus.pdf

DIFFERENT

  ENG101/final_essay.docx
```

Think of this as the equivalent of `git status` for your source and destination directories.

Need it in a script or another tool? Add `--json`:

```bash
rcc-sync status --json
```

```json
{"local_root":"/home/user/College","remote_root":"/home/user/OneDrive/College","up_to_date":false,"local_only":["CIS120/lab3.pdf"],"remote_only":["MTH111Z/syllabus.pdf"],"different":["ENG101/final_essay.docx"],"last_sync":{"timestamp":"2026-07-26 14:32:10","operation":"push all","files":3,"bytes":204818,"duration_seconds":1.4}}
```

> [!NOTE]
> `status`/`diff` currently show every difference regardless of any configured excludes (see [Include / Exclude Patterns](#include--exclude-patterns)). What actually gets transferred by `push`/`pull`/`mirror` of a whole tree honors excludes; `status`/`diff` don't filter them out yet.

---

### Detailed Differences

```bash
rcc-sync diff
```

Displays raw `diff -rq` output between local and destination directories.

---

### Push / Pull Operations

#### Push Everything

```bash
rcc-sync push all
```

#### Pull Everything

```bash
rcc-sync pull all
```

#### Push / Pull Multiple Files

Pass one or more relative paths:

```bash
rcc-sync push file CIS120/lab3.pdf MTH111Z/homework.pdf
rcc-sync pull file ENG101/essay.docx
```

Shell brace expansion works too:

```bash
rcc-sync push file CIS120/{lab1.pdf,lab2.pdf,lab3.pdf}
rcc-sync pull file MTH111Z/{hw1.pdf,hw2.pdf}
```

#### Push / Pull a Directory

```bash
rcc-sync push dir CIS120
rcc-sync pull dir CIS120
```

#### Large Transfer Confirmation

If a push, pull, or mirror would move at least `CONFIRM_FILE_THRESHOLD` files or `CONFIRM_SIZE_THRESHOLD_MB` of data, RCC Sync shows a quick summary and asks you to confirm before continuing:

```text
WARNING: This push looks large: 214 file(s), 1.2 GB.
Continue? [y/N]:
```

Skip the prompt for a single run with `--yes`/`-y`, or turn it off entirely by setting either threshold to `0` in config. The prompt is also skipped automatically in `--quiet` mode and whenever there's no interactive terminal to ask on (for example, when a command is run from inside the `--tui` menu, since those runs already went through their own on-screen confirmation).

---

### Dry-Run Preview

Preview changes before making them:

```bash
rcc-sync dry-push all
rcc-sync dry-pull all
```

<img width="1854" height="969" alt="DryPush" src="https://github.com/user-attachments/assets/8201ae48-71f4-4fea-aa7a-b64970ec722b" />

---

### Transfer Statistics

Every real push, pull, mirror, or restore prints a short summary when it finishes:

```text
Transfer statistics
  Files transferred: 17
  Bytes transferred: 8.2 MB
  Duration: 2.1s
```

Suppress it (along with other routine output) with `--quiet`/`-q` — the numbers are still recorded in the sync history either way.

---

### Sync History

Every push, pull, mirror, and restore is logged with a timestamp:

```bash
rcc-sync history
```

```text
Sync history (most recent 20):

  2026-07-26 14:32:10  push all                3 files,   8.2 MB, 2.1s
  2026-07-26 13:05:44  mirror local→remote     0 files,    0.0 B, 0.4s
  2026-07-25 09:12:03  pull dir: CIS120         6 files,   1.1 MB, 0.9s
```

Show a different number of entries, or clear the log:

```bash
rcc-sync history 50
rcc-sync history clear
```

The most recent entry is also shown by `rcc-sync status` and `rcc-sync config` as "Last sync", and by `rcc-sync status --json` as `last_sync`. The log lives at `~/.config/rcc-sync/history.log`.

---

### Include / Exclude Patterns

Keep specific files or folders out of `push`/`pull`/`mirror` of a whole tree (`all`, `dir`, and `mirror` — not `push file`/`pull file`, which always sync exactly the files you name).

Three ways to configure excludes, all optional and combinable:

1. **`EXCLUDE_FILE`** in config — a path to a file of rsync-style patterns, one per line.
2. **A `.rccsyncignore` file** at the root of `LOCAL_ROOT` — same format, always honored automatically if present, like a `.gitignore`.
3. **`EXCLUDE_PATTERNS`** in config — a quick comma-separated list for a few inline patterns, e.g.:

   ```text
   EXCLUDE_PATTERNS=*.tmp,node_modules,.DS_Store
   ```

---

### Verbose and Quiet Modes

Control output verbosity:

```bash
rcc-sync push all --quiet
rcc-sync pull dir CIS120 --verbose
```

- `--quiet` (`-q`): Suppresses standard output (errors/warnings still show)
- `--verbose`: Increases verbosity

Global flags can go before or after the command — `rcc-sync push all --quiet` and `rcc-sync --quiet push all` both work. Use `--` to stop flag parsing if you ever need to sync a path that happens to look like a flag, e.g. `push file -- --yes`.

---

### Mirror Operations

> [!WARNING]
> Mirror is a **destructive** operation. It uses `rsync --delete` to make the target an exact copy of the source. Files in the target that do not exist in the source **will be permanently deleted**.

A compressed snapshot of the target directory is automatically saved to `ARCHIVE_DIR` before every mirror operation, and can be restored afterward with `rcc-sync restore` — see [Snapshots & Restore](#snapshots--restore).

#### Mirror Local → Remote

Makes remote an exact copy of local:

```bash
rcc-sync mirror local
```

#### Mirror Remote → Local

Makes local an exact copy of remote:

```bash
rcc-sync mirror remote
```

#### Dry-Mirror (Preview, No Changes)

```bash
rcc-sync dry-mirror local
rcc-sync dry-mirror remote
```

Output is clearly labelled to show which files **would be deleted**.

---

### Snapshots & Restore

Before every live `mirror`, a compressed tarball of the target directory is saved:

```text
~/.rcc-sync-archives/rcc-sync-snapshot-remote-20260724-014832.tar.gz
```

Snapshots are named with a timestamp so you can restore to any previous state.

By default snapshots go to `~/.rcc-sync-archives/` (outside OneDrive — never uploaded). To keep cloud-backed snapshots instead, set in `~/.config/rcc-sync/config`:

```text
ARCHIVE_DIR=~/OneDrive/RCC-Sync_Archives
```

#### Restoring a Snapshot

```bash
rcc-sync restore
```

With no name, RCC Sync lists the available snapshots and asks which to restore. You can also name one directly (a full or partial filename both work):

```bash
rcc-sync restore rcc-sync-snapshot-remote-20260724-014832.tar.gz
rcc-sync restore 20260724
```

Restoring **overlays** the snapshot onto its original location (`LOCAL_ROOT` or `REMOTE_ROOT`, whichever it was taken from) — files in the snapshot overwrite matching files there, but anything already in place that isn't part of the snapshot is left alone. It never deletes. A fresh safety snapshot of the current state is taken automatically before the overlay begins, so a restore can itself be undone the same way.

---

### Interactive TUI

RCC Sync includes a menu-driven terminal interface.

Launch it with:

```bash
rcc-sync --tui
```

or

```bash
rcc-sync -t
```

If `whiptail` or `dialog` is installed, RCC Sync automatically uses a full-screen TUI with:

- A **Loading...** progress gauge displayed while any operation runs (no raw terminal flicker)
- A **file checklist picker** and **directory browser** for push/pull operations (no manual path typing)
- A **Search** functionality to quickly filter and sync files by name or extension
- **Customizable Color Themes** (Standard, Dark Mode, Deep Ocean, and Matrix)
- A **Live Status view** that auto-refreshes your sync status
- A **Restore** menu for picking and restoring a snapshot
- A **History** view of recent sync operations
- A **Validate configuration** screen
- A **Keyboard shortcuts** help screen
- An explicit **⚠ WARNING** confirmation screen (defaulting to **No**) before any mirror or restore operation

<img width="1854" height="969" alt="TUI" src="https://github.com/user-attachments/assets/57bb9ffc-b572-4a8a-8881-8649c8cd96d2" />
<img width="1854" height="969" alt="FileSelect" src="https://github.com/user-attachments/assets/1dd81cd9-e56a-431c-8622-03e8dad50ec3" />
<img width="1854" height="969" alt="Loading" src="https://github.com/user-attachments/assets/61c8e838-1335-46a8-9cda-25c7eb83071a" />


If neither `whiptail` nor `dialog` is installed, RCC Sync automatically falls back to a plain-text numbered menu with the same functionality, including a `YES`-typed confirmation requirement for mirror operations.

No additional configuration is required.

---

### Shell Completions

Native shell completions are provided for **Bash**, **Zsh**, **Fish**, and **Nushell**.

When installed via the provided AUR package or Nix flake, these are automatically placed into the correct system directories so you get smart tab-completion for all `rcc-sync` commands, flags, and file paths.

---

## Requirements

### Required

- Bash
- rsync
- diffutils
- tar (for snapshots/restore — included by default on virtually every Linux system)

#### Arch Linux

```bash
sudo pacman -S rsync diffutils tar
```

#### Fedora

```bash
sudo dnf install rsync diffutils tar
```

#### Debian / Ubuntu

```bash
sudo apt install rsync diffutils tar
```

#### NixOS

The flake wraps all runtime dependencies automatically. No extra packages are needed beyond what the flake provides.

If installing manually:

```nix
environment.systemPackages = with pkgs; [
  rsync
  diffutils
  gnutar
];
```

---

### Optional (Enhanced TUI)

`whiptail` (provided by the `newt` package) is recommended. `dialog` also works.

#### Arch Linux

```bash
sudo pacman -S libnewt
```

#### Fedora

```bash
sudo dnf install newt
```

#### Debian / Ubuntu

```bash
sudo apt install whiptail
```

#### NixOS

The flake already includes `newt` (whiptail). No extra packages needed.

---

## OneDrive Setup (Required)

RCC Sync does **not** communicate directly with Microsoft's cloud services.

Instead, it relies on a separate OneDrive client to synchronize a local directory with Microsoft OneDrive.

The recommended client is:

### abraunegg/onedrive

Repository: https://github.com/abraunegg/onedrive

Documentation: https://abraunegg.github.io/

Supported services include:

- OneDrive Personal
- OneDrive for Business
- Microsoft 365 Education
- SharePoint Libraries

---

### Install OneDrive

#### NixOS

Add `onedrive` to your configuration:

```nix
environment.systemPackages = with pkgs; [
  onedrive
];
```

Apply the change:

```bash
sudo nixos-rebuild switch
```

---

#### Arch Linux

```bash
sudo pacman -S onedrive
```

---

#### Fedora

```bash
sudo dnf install onedrive
```

---

#### Debian / Ubuntu

Refer to the official installation instructions: https://abraunegg.github.io/

Package availability may vary by release.

---

### Authenticate Your Account

Run:

```bash
onedrive
```

The client will generate a Microsoft authentication URL.

1. Open the URL in a browser.
2. Sign in using your Microsoft or school account.
3. Approve access.
4. Copy the final redirect URL.
5. Paste the URL back into the terminal.

Once complete, your account is linked.

---

### Create a OneDrive Sync Root

```bash
mkdir -p ~/OneDrive
```

---

### Configure OneDrive

```bash
mkdir -p ~/.config/onedrive
nano ~/.config/onedrive/config
```

Set:

```ini
sync_dir = "~/OneDrive"
```

---

### Initial Synchronization

Preview changes first:

```bash
onedrive --sync --dry-run
```

Perform the actual sync:

```bash
onedrive --sync
```

---

### Optional: Background Synchronization

Enable the included systemd user service:

```bash
systemctl --user enable onedrive
systemctl --user start onedrive
```

Check status:

```bash
systemctl --user status onedrive
```

---

## Example Directory Layout

```text
~/College
├── CIS120
├── MTH111Z
├── ENG101
└── Notes

~/OneDrive
├── College
├── Documents
├── Attachments
└── Recordings

~/.rcc-sync-archives
└── rcc-sync-snapshot-remote-20260724-014832.tar.gz
```

RCC Sync is typically configured as:

```text
LOCAL_ROOT   = ~/College
REMOTE_ROOT  = ~/OneDrive/College
ARCHIVE_DIR  = ~/.rcc-sync-archives
```

Resulting workflow:

```text
~/College
      ↑
      │  rcc-sync
      ↓
~/OneDrive/College
      ↑
      │  abraunegg/onedrive
      ↓
Microsoft OneDrive
```

---

## Installation

### Via Nix Flake (Recommended on NixOS)

```bash
nix profile add github:Skeome/rcc-sync
```

All runtime dependencies (rsync, diffutils, tar, whiptail) are bundled automatically.

To update:

```bash
nix profile remove rcc-sync
nix profile add github:Skeome/rcc-sync
```

---

### Manual Installation

Clone the repository:

```bash
git clone https://github.com/Skeome/rcc-sync.git
cd rcc-sync
```

Make the script executable:

```bash
chmod +x rcc-sync
```

Install system-wide:

```bash
sudo install -Dm755 rcc-sync /usr/local/bin/rcc-sync
```

Verify installation:

```bash
rcc-sync version
```

Expected output:

```text
rcc-sync v1.2.0
```

---

## Quick Start

Create a configuration:

```bash
rcc-sync init
```

View configuration:

```bash
rcc-sync config
```

Check status:

```bash
rcc-sync status
```

Preview a synchronization:

```bash
rcc-sync dry-push all
```

Push local changes:

```bash
rcc-sync push all
```

Launch the TUI:

```bash
rcc-sync --tui
```

---

## Example Workflow

Work on files locally:

```text
~/College/CIS120
```

Check differences:

```bash
rcc-sync status
```

Preview changes:

```bash
rcc-sync dry-push all
```

Push specific files:

```bash
rcc-sync push file CIS120/{lab3.pdf,notes.md}
```

Or push everything:

```bash
rcc-sync push all
```

Allow your OneDrive client to synchronize:

```text
~/OneDrive/College
        ↓
Microsoft OneDrive
```

Made a mistake with a mirror? Undo it:

```bash
rcc-sync restore
```

---

## Philosophy

RCC Sync intentionally borrows ideas from version-control systems.

| Git | RCC Sync |
| --- | --- |
| Working Tree | Local Workspace |
| Remote Repository | Sync Destination |
| `git status` | `rcc-sync status` |
| `git diff` | `rcc-sync diff` |
| `git push` | `rcc-sync push` |
| `git pull` | `rcc-sync pull` |
| `git log` | `rcc-sync history` |
| `.gitignore` | `.rccsyncignore` / `EXCLUDE_FILE` |
| `git reset --hard` | `rcc-sync mirror` ⚠ |
| `git revert` | `rcc-sync restore` |

RCC Sync is **not** a replacement for Git.

Instead, it applies similar principles to coursework, notes, documents, and cloud-backed storage.

The guiding philosophy is simple:

```text
Make changes intentionally.
Review changes intentionally.
Synchronize intentionally.
```

---

## Current Version

```text
rcc-sync v1.2.0
```

New in v1.2.0: `config validate`, `restore`, `history`, transfer statistics, `status --json`, include/exclude patterns, a confirmation prompt before unusually large transfers, and safer path handling for `push`/`pull` of explicitly named files and directories.

---

## License

MIT License

---

## Contributing

Issues, bug reports, feature requests, and pull requests are welcome.

If you're a Linux user, student, educator, or OneDrive user interested in explicit synchronization workflows, contributions are greatly appreciated.
