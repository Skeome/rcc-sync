# RCC Sync

> Work locally. Sync intentionally.

RCC Sync is a lightweight Linux utility that provides explicit, non-destructive synchronization between a local workspace and a OneDrive-backed directory.

Unlike traditional cloud synchronization tools, RCC Sync never runs in the background and never automatically uploads, downloads, or deletes files.

RCC Sync assumes you already have a OneDrive client synchronizing your local OneDrive directory with Microsoft's cloud services.

The most common setup is:

```text
~/College
    ↑
    │  (rcc-sync)
    ↓
~/OneDrive/College
    ↑
    │  (OneDrive Client)
    ↓
Microsoft OneDrive
```

---

## Why RCC Sync?

Traditional sync tools typically follow this workflow:

```text
Edit File
    ↓
Immediate Upload
    ↓
Cloud
```

RCC Sync takes a different approach:

```text
Edit File
    ↓
Review Changes
    ↓
Preview Synchronization
    ↓
Manual Push/Pull
    ↓
Cloud
```

This workflow is particularly useful for:

- Students
- Linux users
- Version-control minded users
- Users who prefer explicit synchronization
- Users who want to avoid accidental cloud updates

RCC Sync was originally developed for Linux users at Rogue Community College but is useful anywhere Linux and OneDrive intersect.

---

## Features

### Safe by Default

RCC Sync push/pull operations:

✅ Never delete files

✅ Never sync automatically

✅ Never talk to the network themselves

✅ Require explicit user actions

✅ Support dry-run previews

> [!NOTE]
> The `mirror` command intentionally uses `rsync --delete` and **will** delete files in the target directory. A backup snapshot is always created automatically before any mirror operation. See [Mirror Operations](#mirror-operations) below.

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
```

| Key | Default | Description |
| --- | --- | --- |
| `LOCAL_ROOT` | `~/College` | Your local working directory |
| `REMOTE_ROOT` | `~/OneDrive/College` | OneDrive-backed mirror directory |
| `ARCHIVE_DIR` | `~/.rcc-sync-archives` | Where pre-mirror backup snapshots are saved |

> [!TIP]
> Set `ARCHIVE_DIR=~/OneDrive/RCC-Sync_Archives` to have your backup snapshots automatically uploaded to the cloud by your OneDrive client.

---

### Status Reporting

```bash
rcc-sync status
```

Example output:

```text
LOCAL ONLY

  CIS120/lab3.pdf

REMOTE ONLY

  MTH111Z/syllabus.pdf

DIFFERENT

  ENG101/final_essay.docx
```

Think of this as the equivalent of `git status` for your local and cloud-backed directories.

---

### Detailed Differences

```bash
rcc-sync diff
```

Displays raw `diff -rq` output between local and OneDrive-backed directories.

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

---

### Dry-Run Preview

Preview changes before making them:

```bash
rcc-sync dry-push all
rcc-sync dry-pull all
```

---

### Mirror Operations

> [!WARNING]
> Mirror is a **destructive** operation. It uses `rsync --delete` to make the target an exact copy of the source. Files in the target that do not exist in the source **will be permanently deleted**.

A compressed snapshot of the target directory is automatically saved to `ARCHIVE_DIR` before every mirror operation.

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

### Backup Snapshots

Before every live `mirror`, a compressed tarball of the target directory is saved:

```text
~/.rcc-sync-archives/rcc-sync-snapshot-remote-20260724-014832.tar.gz
```

Snapshots are named with a timestamp so you can restore to any previous state.

By default snapshots go to `~/.rcc-sync-archives/` (outside OneDrive — never uploaded). To keep cloud-backed snapshots instead, set in `~/.config/rcc-sync/config`:

```text
ARCHIVE_DIR=~/OneDrive/RCC-Sync_Archives
```

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
- A **file checklist picker** for push/pull file operations (no manual path typing)
- An explicit **⚠ WARNING** confirmation screen (defaulting to **No**) before any mirror operation

```text
┌──────────────── RCC Sync v0.1 ─────────────────┐
│ Choose an action:                               │
│                                                 │
│   Status                                        │
│   Diff                                          │
│   Push                                          │
│   Pull                                          │
│   ⚠  Mirror — destructive exact sync           │
│   Dry Push                                      │
│   Dry Pull                                      │
│   Config                                        │
│   Setup / change config                         │
│   Quit                                          │
└─────────────────────────────────────────────────┘
```

If neither `whiptail` nor `dialog` is installed, RCC Sync automatically falls back to a plain-text numbered menu with the same functionality, including a `YES`-typed confirmation requirement for mirror operations.

No additional configuration is required.

---

## Requirements

### Required

- Bash
- rsync
- diffutils

#### Arch Linux

```bash
sudo pacman -S rsync diffutils
```

#### Fedora

```bash
sudo dnf install rsync diffutils
```

#### Debian / Ubuntu

```bash
sudo apt install rsync diffutils
```

#### NixOS

The flake wraps all runtime dependencies automatically. No extra packages are needed beyond what the flake provides.

If installing manually:

```nix
environment.systemPackages = with pkgs; [
  rsync
  diffutils
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

## Recommended Directory Layout

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

All runtime dependencies (rsync, diffutils, whiptail) are bundled automatically.

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
rcc-sync v1.0.0
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

---

## Philosophy

RCC Sync intentionally borrows ideas from version-control systems.

| Git | RCC Sync |
| --- | --- |
| Working Tree | Local Workspace |
| Remote Repository | OneDrive |
| `git status` | `rcc-sync status` |
| `git diff` | `rcc-sync diff` |
| `git push` | `rcc-sync push` |
| `git pull` | `rcc-sync pull` |
| `git reset --hard` | `rcc-sync mirror` ⚠ |

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
rcc-sync v1.0.0
```

---

## License

MIT License

---

## Contributing

Issues, bug reports, feature requests, and pull requests are welcome.

If you're a Linux user, student, educator, or OneDrive user interested in explicit synchronization workflows, contributions are greatly appreciated.
