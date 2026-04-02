#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${NVIM_DOTFILES_REPO_URL:-https://github.com/mehmetarslanca/nvim-dotfiles.git}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG_DIR="${CONFIG_HOME}/nvim"

log() {
  printf '[nvim-dotfiles] %s\n' "$*"
}

have() {
  command -v "$1" >/dev/null 2>&1
}

run_privileged() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

backup_existing_config() {
  if [ ! -e "$CONFIG_DIR" ]; then
    return
  fi

  local backup_dir="${CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$CONFIG_DIR" "$backup_dir"
  log "Existing config backed up to $backup_dir"
}

clone_or_update_repo() {
  mkdir -p "$CONFIG_HOME"

  if [ -d "$CONFIG_DIR/.git" ]; then
    local remote_url
    remote_url="$(git -C "$CONFIG_DIR" remote get-url origin 2>/dev/null || true)"
    if [ "$remote_url" = "$REPO_URL" ] || [ "$remote_url" = "${REPO_URL%.git}" ]; then
      log "Updating existing nvim-dotfiles checkout"
      git -C "$CONFIG_DIR" pull --ff-only
      return
    fi
  fi

  if [ -e "$CONFIG_DIR" ]; then
    backup_existing_config
  fi

  log "Cloning nvim-dotfiles into $CONFIG_DIR"
  git clone "$REPO_URL" "$CONFIG_DIR"
}

install_with_apt() {
  run_privileged apt-get update
  run_privileged apt-get install -y git curl unzip tar gzip ripgrep fd-find neovim nodejs npm default-jdk
}

install_with_pacman() {
  run_privileged pacman -Sy --noconfirm git curl unzip tar gzip ripgrep fd neovim nodejs npm jdk-openjdk
}

install_with_dnf() {
  run_privileged dnf install -y git curl unzip tar gzip ripgrep fd-find neovim nodejs npm java-latest-openjdk
}

install_with_zypper() {
  run_privileged zypper --non-interactive install git curl unzip tar gzip ripgrep fd neovim nodejs npm java-latest-openjdk
}

install_with_brew() {
  if ! have brew; then
    log "Homebrew not found. Install Homebrew first: https://brew.sh"
    return
  fi

  brew install git neovim ripgrep fd node openjdk
}

install_dependencies() {
  case "$(uname -s)" in
    Darwin)
      install_with_brew
      ;;
    Linux)
      if have apt-get; then
        install_with_apt
      elif have pacman; then
        install_with_pacman
      elif have dnf; then
        install_with_dnf
      elif have zypper; then
        install_with_zypper
      else
        log "No supported package manager detected. Make sure git, neovim, nodejs, npm, ripgrep and a JDK are installed."
      fi
      ;;
    *)
      log "Unsupported OS for install.sh"
      ;;
  esac
}

bootstrap_neovim() {
  if ! have git; then
    log "git is required but not installed."
    exit 1
  fi

  if ! have nvim; then
    log "neovim is required but not installed."
    exit 1
  fi

  log "Installing plugins via Lazy"
  nvim --headless "+Lazy! sync" +qa

  log "Triggering startup so Mason tools can restore"
  nvim --headless +qa
}

main() {
  install_dependencies
  clone_or_update_repo
  bootstrap_neovim
  log "Restore complete"
}

main "$@"
