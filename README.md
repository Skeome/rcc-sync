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

# Why RCC Sync?

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

# Features

## Safe by Default

RCC Sync:

✅ Never deletes files

✅ Never syncs automatically

✅ Never talks to the network itself

✅ Requires explicit user actions

✅ Supports dry-run previews

✅ Never overwrites directories through mirroring operations

---

## Configuration Support

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
```

---

## Status Reporting

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

Think of this as the equivalent of:

```bash
git status
```

for your local and cloud-backed directories.

---

## Detailed Differences

```bash
rcc-sync diff
```

Displays raw `diff -rq` output between local and OneDrive-backed directories.

---

## Push / Pull Operations

### Push Everything

```bash
rcc-sync push all
```

### Pull Everything

```bash
rcc-sync pull all
```

---

## Dry-Run Preview

Preview changes before making them:

```bash
rcc-sync dry-push all
```

```bash
rcc-sync dry-pull all
```

---

## Individual File Synchronization

Push a single file:

```bash
rcc-sync push file CIS120/report.docx
```

Pull a single file:

```bash
rcc-sync pull file CIS120/report.docx
```

---

## Directory Synchronization

Push a directory:

```bash
rcc-sync push dir CIS120
```

Pull a directory:

```bash
rcc-sync pull dir CIS120
```

---

## Interactive TUI

RCC Sync includes a menu-driven terminal interface.

Launch it with:

```bash
rcc-sync --tui
```

or

```bash
rcc-sync -t
```

If `whiptail` or `dialog` is installed, RCC Sync automatically uses a full-screen TUI.

Example menu:

```text
Status
Diff
Push
Pull
Dry Push
Dry Pull
Config
Init
Quit
```

If neither dependency is installed, RCC Sync automatically falls back to a plain-text interactive interface.

No additional configuration is required.

---

# Requirements

## Required

- Bash
- rsync
- diffutils

### Arch Linux

```bash
sudo pacman -S rsync diffutils
```

### Fedora

```bash
sudo dnf install rsync diffutils
```

### Debian / Ubuntu

```bash
sudo apt install rsync diffutils
```

### NixOS

```nix
environment.systemPackages = with pkgs; [
  rsync
  diffutils
];
```

---

## Optional

For the enhanced TUI experience:

### Arch Linux

```bash
sudo pacman -S dialog
```

### Fedora

```bash
sudo dnf install dialog
```

### Debian / Ubuntu

```bash
sudo apt install dialog
```

### NixOS

```nix
environment.systemPackages = with pkgs; [
  dialog
];
```

---

# OneDrive Setup (Required)

RCC Sync does **not** communicate directly with Microsoft's cloud services.

Instead, it relies on a separate OneDrive client to synchronize a local directory with Microsoft OneDrive.

The recommended client is:

## abraunegg/onedrive

Repository:

https://github.com/abraunegg/onedrive

Documentation:

https://abraunegg.github.io/

Supported services include:

- OneDrive Personal
- OneDrive for Business
- Microsoft 365 Education
- SharePoint Libraries

---

## Install OneDrive

### NixOS

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

### Arch Linux

```bash
sudo pacman -S onedrive
```

---

### Fedora

```bash
sudo dnf install onedrive
```

---

### Debian / Ubuntu

Refer to the official installation instructions:

https://abraunegg.github.io/

Package availability may vary by release.

---

## Authenticate Your Account

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

## Create a OneDrive Sync Root

Create a dedicated local sync location:

```bash
mkdir -p ~/OneDrive
```

---

## Configure OneDrive

Create the configuration directory:

```bash
mkdir -p ~/.config/onedrive
```

Edit the configuration file:

```bash
nano ~/.config/onedrive/config
```

Set:

```ini
sync_dir = "~/OneDrive"
```

---

## Initial Synchronization

Preview changes first:

```bash
onedrive --sync --dry-run
```

Perform the actual sync:

```bash
onedrive --sync
```

---

## Optional: Background Synchronization

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

# Recommended Directory Layout

Once OneDrive is configured, your directories may look like this:

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
```

RCC Sync is typically configured as:

```text
LOCAL_ROOT  = ~/College
REMOTE_ROOT = ~/OneDrive/College
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

This separation allows users to keep an independent working directory while still maintaining cloud-backed copies when desired.

---

# Installation

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
rcc-sync v0.1
```

---

# Quick Start

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

# Example Workflow

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

Push updates:

```bash
rcc-sync push all
```

Allow your OneDrive client to synchronize:

```text
~/OneDrive/College
        ↓
Microsoft OneDrive
```

This approach is closer to a version-control workflow than traditional cloud synchronization.

---

# Philosophy

RCC Sync intentionally borrows ideas from version-control systems.

| Git | RCC Sync |
|------|------|
| Working Tree | Local Workspace |
| Remote Repository | OneDrive |
| git status | rcc-sync status |
| git diff | rcc-sync diff |
| git push | rcc-sync push |
| git pull | rcc-sync pull |

RCC Sync is **not** a replacement for Git.

Instead, it applies similar principles to coursework, notes, documents, and cloud-backed storage.

The guiding philosophy is simple:

```text
Make changes intentionally.
Review changes intentionally.
Synchronize intentionally.
```

---

# Current Version

```text
rcc-sync v0.1
```

---

# Roadmap

Planned future enhancements include:

- Additional filtering options
- Better status reporting
- Path completion
- Synchronization profiles
- Package manager distribution
- Enhanced TUI functionality
- Snapshot and backup support

---

# License

MIT License

---

# Contributing

Issues, bug reports, feature requests, and pull requests are welcome.

If you're a Linux user, student, educator, or OneDrive user interested in explicit synchronization workflows, contributions are greatly appreciated.