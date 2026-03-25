#!/bin/bash
# ============================================================================
# Git Bash Terminal Tweaks - Installation Script
# ============================================================================
# This script installs bash configuration tweaks to your Git Bash setup.
# It backs up your existing .bashrc and merges the tweaks.
#
# Usage: bash install.sh

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASHRC_FILE="$HOME/.bashrc"
BASHRC_BACKUP="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
TWEAKS_FILE="$SCRIPT_DIR/.bashrc-tweaks"
PODMAN_FILE="$SCRIPT_DIR/.bashrc-podman"
TWEAKS_TARGET="$HOME/.bashrc-tweaks"
PODMAN_TARGET="$HOME/.bashrc-podman"

# Markers to prevent duplicate sourcing
TWEAKS_MARKER="# git-bash-terminal-tweaks: .bashrc-tweaks"
PODMAN_MARKER="# git-bash-terminal-tweaks: .bashrc-podman"

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
  echo ""
  echo "=========================================="
  echo "$1"
  echo "=========================================="
  echo ""
}

print_success() {
  echo "✓ $1"
}

print_info() {
  echo "ℹ $1"
}

print_warning() {
  echo "⚠ $1"
}

print_error() {
  echo "✗ $1"
}

# ============================================================================
# VALIDATION
# ============================================================================

print_header "Git Bash Terminal Tweaks - Installation"


# Check if tweaks files exist in repo
if [[ ! -f "$TWEAKS_FILE" ]]; then
  print_error ".bashrc-tweaks not found at: $TWEAKS_FILE"
  exit 1
fi
print_success "Found .bashrc-tweaks in repo"

if [[ ! -f "$PODMAN_FILE" ]]; then
  print_error ".bashrc-podman not found at: $PODMAN_FILE"
  exit 1
fi
print_success "Found .bashrc-podman in repo"


# Copy tweaks files to home directory, with verification
copy_with_prompt() {
  local src="$1"
  local dest="$2"
  local label="$3"
  if [[ -f "$dest" ]]; then
    if cmp -s "$src" "$dest"; then
      print_info "$label already up to date in home directory (skipping)"
      return 0
    else
      print_warning "$label already exists and differs from repo version."
      read -p "Overwrite $dest with repo version? (y/n) [n]: " -r OVERWRITE
      OVERWRITE=${OVERWRITE:-n}
      if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        cp "$src" "$dest"
        print_success "Overwrote $dest with repo version."
      else
        print_info "Skipped overwriting $dest."
      fi
    fi
  else
    cp "$src" "$dest"
    print_success "Copied $label to $dest"
  fi
}

# Always check/copy tweaks
copy_with_prompt "$TWEAKS_FILE" "$TWEAKS_TARGET" ".bashrc-tweaks"

# Podman: only prompt if file exists and differs, otherwise copy silently or skip
PODMAN_EXISTS=0
if [[ -f "$PODMAN_TARGET" ]]; then
  PODMAN_EXISTS=1
  if cmp -s "$PODMAN_FILE" "$PODMAN_TARGET"; then
    print_info ".bashrc-podman already up to date in home directory (skipping)"
  else
    print_warning ".bashrc-podman already exists and differs from repo version."
    read -p "Overwrite $PODMAN_TARGET with repo version? (y/n) [n]: " -r OVERWRITE_PODMAN
    OVERWRITE_PODMAN=${OVERWRITE_PODMAN:-n}
    if [[ "$OVERWRITE_PODMAN" =~ ^[Yy]$ ]]; then
      cp "$PODMAN_FILE" "$PODMAN_TARGET"
      print_success "Overwrote $PODMAN_TARGET with repo version."
    else
      print_info "Skipped overwriting $PODMAN_TARGET."
    fi
  fi
else
  cp "$PODMAN_FILE" "$PODMAN_TARGET"
  print_success "Copied .bashrc-podman to $PODMAN_TARGET"
fi

# ============================================================================
# BACKUP EXISTING .bashrc
# ============================================================================

if [[ -f "$BASHRC_FILE" ]]; then
  cp "$BASHRC_FILE" "$BASHRC_BACKUP"
  print_success "Backed up existing .bashrc to: $BASHRC_BACKUP"
else
  print_info "No existing .bashrc found (will be created)"
  touch "$BASHRC_FILE"
fi

# ============================================================================
# SOURCE TWEAKS
# ============================================================================



# Remove any existing .bashrc-tweaks marker+quoted source lines
if grep -q "$TWEAKS_MARKER" "$BASHRC_FILE"; then
  # Remove lines from marker to next blank or comment
  awk 'BEGIN{skip=0} {if ($0 ~ /# git-bash-terminal-tweaks: .bashrc-tweaks/) {skip=1; next} if (skip && ($0 ~ /^$/ || $0 ~ /^#/)) {skip=0} if (!skip) print $0}' "$BASHRC_FILE" > "$BASHRC_FILE.tmp" && mv "$BASHRC_FILE.tmp" "$BASHRC_FILE"
fi
# Append correct marker and unquoted source
{
  echo ""
  echo "$TWEAKS_MARKER"
  echo "source ~/.bashrc-tweaks"
} >> "$BASHRC_FILE"
print_success "Ensured .bashrc-tweaks is sourced correctly in $BASHRC_FILE"

# ============================================================================
# OPTIONAL: SOURCE PODMAN ALIASES
# ============================================================================


# Remove any existing .bashrc-podman marker+quoted source lines
if [[ -f "$PODMAN_TARGET" ]]; then
  if grep -q "$PODMAN_MARKER" "$BASHRC_FILE"; then
    awk 'BEGIN{skip=0} {if ($0 ~ /# git-bash-terminal-tweaks: .bashrc-podman/) {skip=1; next} if (skip && ($0 ~ /^$/ || $0 ~ /^#/)) {skip=0} if (!skip) print $0}' "$BASHRC_FILE" > "$BASHRC_FILE.tmp" && mv "$BASHRC_FILE.tmp" "$BASHRC_FILE"
  fi
  # Always append correct marker and unquoted source
  {
    echo ""
    echo "$PODMAN_MARKER"
    echo "source ~/.bashrc-podman"
  } >> "$BASHRC_FILE"
  print_success "Ensured .bashrc-podman is sourced correctly in $BASHRC_FILE"
fi

# ============================================================================
# DISPLAY SUMMARY
# ============================================================================


# ============================================================================
# ENSURE ~/.bash_profile EXISTS AND LOADS ~/.bashrc
# ============================================================================
BASH_PROFILE_FILE="$HOME/.bash_profile"
BASH_PROFILE_MARKER="# git-bash-terminal-tweaks: source .bashrc"
if [[ ! -f "$BASH_PROFILE_FILE" ]]; then
  echo "$BASH_PROFILE_MARKER" > "$BASH_PROFILE_FILE"
  echo "if [ -f \"$BASHRC_FILE\" ]; then" >> "$BASH_PROFILE_FILE"
  echo "  source \"$BASHRC_FILE\"" >> "$BASH_PROFILE_FILE"
  echo "fi" >> "$BASH_PROFILE_FILE"
  print_success "Created ~/.bash_profile to source ~/.bashrc (for login shells)"
else
  # If .bash_profile exists but doesn't source .bashrc, append it
  if ! grep -q "$BASH_PROFILE_MARKER" "$BASH_PROFILE_FILE" && ! grep -q "source.*\\.bashrc" "$BASH_PROFILE_FILE"; then
    echo "" >> "$BASH_PROFILE_FILE"
    echo "$BASH_PROFILE_MARKER" >> "$BASH_PROFILE_FILE"
    echo "if [ -f \"$BASHRC_FILE\" ]; then" >> "$BASH_PROFILE_FILE"
    echo "  source \"$BASHRC_FILE\"" >> "$BASH_PROFILE_FILE"
    echo "fi" >> "$BASH_PROFILE_FILE"
    print_success "Updated ~/.bash_profile to source ~/.bashrc (for login shells)"
  else
    print_info "~/.bash_profile already sources ~/.bashrc (skipping)"
  fi
fi

print_header "Installation Complete!"

print_success "Git Bash tweaks have been installed"
print_info ""
print_info "To apply changes immediately, restart Git Bash or run:"
echo "  source ~/.bashrc"
print_info ""
print_info "What's installed:"
echo "  • Shared bash history (keeps history across all sessions)"
echo "  • Productivity aliases (edit-aliases, edit-tweaks, etc.)"
echo "  • Git aliases (gst, ga, gc, gd, etc.)"
echo "  • Navigation shortcuts (cd.., ..., etc.)"
if [[ "$INSTALL_PODMAN" =~ ^[Yy]$ ]]; then
  echo "  • Podman/Docker aliases (docker → podman)"
fi
print_info ""
print_info "To customize further, edit:"
echo "  • ~/.bashrc-tweaks (core aliases and history settings)"
if [[ "$INSTALL_PODMAN" =~ ^[Yy]$ ]]; then
  echo "  • ~/.bashrc-podman (podman/docker aliases)"
fi
print_info ""
print_info "To uninstall, remove the source lines from ~/.bashrc"
print_info "Your original .bashrc is backed up at: $BASHRC_BACKUP"
echo ""
