# git-bash-terminal-tweaks

> Quality of life improvements for Git Bash on Windows

A collection of bash profile configurations and installation scripts to enhance your Git Bash experience with:
- **Shared command history** across all sessions
- **Helpful aliases** for Git, navigation, and productivity
- **Optional podman/docker compatibility** layer
- **Smart installation** with automatic backups and idempotent re-runs

## Features

### Core Tweaks (Always Installed)

#### 🔄 Shared Command History
- Commands persist across all Git Bash sessions
- Large history buffer (10k commands, 20k history file)
- Immediate history updating (not just on exit)

#### 📝 Productivity Aliases
- `edit-aliases` — Quick edit aliases (opens in VS Code)
- `edit-tweaks` — Edit the tweaks configuration
- `ll`, `la`, `l` — Better directory listings
- `cd..`, `...`, `....` — Quick navigation
- `home`, `root` — Jump to common directories

#### 🌿 Git Aliases
- **Status & Staging**: `gst`, `ga`, `gaa`, `gapatch`
- **Commits**: `gc`, `gca`, `gcam`
- **History**: `gl`, `glp` (pretty-print history)
- **Diffs**: `gd`, `gdh`, `gds` (staged diff)
- **Branches**: `gb`, `gba`, `gco`, `gcob`
- **Merge & Pull**: `gm`, `gp`, `gps`
- **Reset & Clean**: `gr`, `grh`, `grs`, `gclean`

### Optional Tweaks

#### 🐳 Podman/Docker Compatibility
- `docker` → `podman` (simple alias)
- `docker-compose` → `podman compose`
- Also includes podman-specific aliases: `pst`, `psta`, `pim`, `prun`, etc.

## Installation

### Prerequisites
- Git Bash for Windows (comes with Git for Windows)
- Bash 4.0+

### Quick Install

1. Navigate to your profile directory or clone this repo:
   ```bash
   cd ~/projects
   git clone https://github.com/yourusername/git-bash-terminal-tweaks.git
   cd git-bash-terminal-tweaks
   ```

2. Run the installation script:
   ```bash
   bash install.sh
   ```

3. Follow the prompts:
   - Choose whether to install podman aliases (optional)
   - Script will back up your existing `.bashrc` automatically

4. Restart Git Bash or reload your profile:
   ```bash
   source ~/.bashrc
   ```

### Manual Installation (without script)

If you prefer to install manually:

1. Copy the config files to your home directory:
   ```bash
   cp .bashrc-tweaks ~/.bashrc-tweaks
   cp .bashrc-podman ~/.bashrc-podman
   ```

2. Add these lines to your `~/.bashrc`:
   ```bash
   source ~/.bashrc-tweaks
   # source ~/.bashrc-podman  # Uncomment to enable podman aliases
   ```

3. Reload your profile:
   ```bash
   source ~/.bashrc
   ```

## Usage

### Viewing Installed Aliases

List all Git aliases:
```bash
alias | grep g
```

List all tweaks:
```bash
alias | grep -E "edit|ll|cd\.\."
```

### Customizing Aliases

Edit the core tweaks:
```bash
edit-tweaks
```

Or manually edit:
```bash
code ~/.bashrc-tweaks
```

After editing, reload your profile:
```bash
source ~/.bashrc
```

### Enabling/Disabling Podman Aliases

To enable podman aliases after initial install:
```bash
echo "" >> ~/.bashrc
echo "# git-bash-terminal-tweaks: .bashrc-podman" >> ~/.bashrc
echo "source ~/.bashrc-podman" >> ~/.bashrc
source ~/.bashrc
```

To disable, remove the source line from `~/.bashrc`:
```bash
edit-aliases  # Then remove the podman source line
```

## File Structure

```
.
├── .bashrc-tweaks       # Core bash configuration + aliases
├── .bashrc-podman       # Optional podman/docker compatibility
├── install.sh           # Installation script (handles backups & sourcing)
├── README.md            # This file
└── LICENSE              # MIT License
```

## How It Works

### Installation Process

The `install.sh` script:

1. **Validates** that both config files exist
2. **Backs up** your existing `~/.bashrc` with a timestamp (e.g., `.bashrc.backup.20260325_143022`)
3. **Sources** `.bashrc-tweaks` from your `~/.bashrc`
4. **Prompts** for optional podman aliases installation
5. **Prevents duplicates** by checking for marker comments before sourcing
6. **Can be re-run safely** — won't add duplicate source lines

### Shared History

The shared history feature:

1. Uses a dedicated file: `~/.bash_history_shared` (instead of default `~/.bash_history`)
2. Appends history instead of overwriting via `shopt -s histappend`
3. Updates history immediately after each command via `history -a`
4. Reads new history from other sessions via `history -n` in `PROMPT_COMMAND`

This means all Git Bash windows see each other's commands in real-time.

## Troubleshooting

### Changes not appearing

Make sure to reload your profile:
```bash
source ~/.bashrc
```

Or restart Git Bash entirely.

### History not shared

Check that `~/.bash_history_shared` exists and is readable:
```bash
ls -la ~/.bash_history_shared
tail -10 ~/.bash_history_shared
```

### Aliases not defined

Verify the tweaks are sourced:
```bash
grep "../bashrc-tweaks" ~/.bashrc
```

If missing, re-run the installer:
```bash
bash install.sh
```

### Git aliases not working

Some Git aliases (like `git stash`) might conflict with shell aliases. Use the full command name if needed:
```bash
/usr/bin/git stash
```

Or prefix with `\`:
```bash
\git stash
```

## Uninstalling

To remove the tweaks:

1. Edit `~/.bashrc` and remove the source lines:
   ```bash
   edit-aliases
   ```

2. Delete the config files:
   ```bash
   rm ~/.bashrc-tweaks ~/.bashrc-podman
   ```

3. (Optional) Restore your backup:
   ```bash
   cp ~/.bashrc.backup.YYYYMMDD_HHMMSS ~/.bashrc
   ```

## Contributing

Found a bug or want to add more aliases? Feel free to:
- Open an issue
- Submit a pull request
- Suggest improvements in discussions

## License

MIT © 2026 Dmytro Derhachov

## See Also

- [Git Documentation - Aliases](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases)
- [Bash Manual - Readline Init File Syntax](https://www.gnu.org/software/bash/manual/html_node/Readline-Init-File-Syntax.html)
- [Podman Documentation](https://docs.podman.io/)
- [Git for Windows](https://gitforwindows.org/)
