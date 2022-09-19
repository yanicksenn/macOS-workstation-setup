#!/usr/bin/env bash

log() {
  echo "$1" | tee -a "$LOGFILE"
}

confirm() {
  local message=$1

  read -r -p "$message [y/N]: " response
  case "$response" in
      [yY][eE][sS]|[yY])
          true
          ;;
      *)
          false
          ;;
  esac
}

command_exists() {
  local command=$1

  if command -v "$command" &> /dev/null; then
    true
  else
    false
  fi
}

setup_xcode() {
  if ! xcode-select -p &> /dev/null; then
    log "  Installing xcode ..."
    xcode-select --install >> "$LOGFILE"
    log "  xcode installed"
  else
    log "  xcode already installed"
  fi
}

setup_brew() {
  if ! command_exists "brew"; then
    log "  Installing brew ..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOGFILE"
    log "  brew installed"
  else
    log "  brew already installed"
  fi
}

brew_install() {
  local name=$1

  if ! brew list "$name" &> /dev/null; then
    log "  Installing $name ..."
    brew install "$name" >> "$LOGFILE"
    log "  $name installed"
  else
    log "  $name already installed"
  fi
}

brew_install_cask() {
  local name=$1

  if ! brew list "$name" &> /dev/null; then
    log "  Installing $name ..."
    brew install --cask "$name" >> "$LOGFILE"
    log "  $name installed"
  else
    log "  $name already installed"
  fi
}

setup_sdkman() {
  if ! command_exists "sdk"; then
    log "  Installing sdkman ..."
    curl -s "https://get.sdkman.io" | bash >> "$LOGFILE"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    log "  sdkman installed"
  else
    log "  sdkman already installed"
  fi
}

sdkman_install() {
  local name=$1
  local version=$2

  local candidate=~/.sdkman/candidates/$name/$version

  if [ ! -d "$candidate" ]; then
    log "  Installing $name $version ..."
    sdkman_install "$name" "$version" >> "$LOGFILE"
    log "  $name $version installed"
  else
    log "  $name $version already installed"
  fi
}


# Python installation

install_pyenv() {
  brew_install pyenv
}

install_pyenv_update() {
  local path=$(pyenv root)/plugins/pyenv-update

  if [ ! -d "$path" ]; then
    log "  Installing pyenv-update ..."
    git clone https://github.com/pyenv/pyenv-update.git "$path" >> "$LOGFILE"
    log "  pyenv-update installed"
  else
    log "  pyenv-update already installed"
  fi
}

install_python_version() {
  local version=$1

  if ! pyenv versions --bare | grep -q "$version"; then
    log "  Installing python $version ..."
    pyenv install -s "$version" >> "$LOGFILE"
    log "  python $version installed"
  else
    log "  python $version already installed"
  fi
}


# Main setup

setup() {
  log "Setup workspace - macOS"
  log "  Version: $VERSION"
  log "  Logfile: $LOGFILE"
  log ""

  if ! confirm "Do you want to continue?"; then
    log "User abort"
    exit 1
  fi
  log ""

  # Install prerequisites
  log "Installing prerequisites ..."
  setup_xcode
  setup_brew
  log ""

  # Install Python & Tools
  log "Installing Python & Tools ..."
  install_pyenv
  install_pyenv_update
  install_python_version "$PYTHON_VERSION"
  log ""

  # Install JDK & JVM Tools
  log "Installing JDK & JVM Tools ..."
  setup_sdkman
  sdkman_install java 17.0.2-open
  sdkman_install kotlin
  sdkman_install maven
  sdkman_install gradle
  log ""

  # Install dev-tools
  log "Installing dev-tools ..."
  brew_install_cask jetbrains-toolbox
  brew_install_cask visual-studio-code
  brew_install_cask cyberduck
  log ""

  # Install utilities
  log "Installing utilities ..."
  brew_install_cask google-chrome
  brew_install_cask grammarly-desktop
  brew_install_cask 1password
  brew_install_cask 1password-cli

  log ""
  log "Setup done."
}

VERSION=1.0.0
LOGFILE=$(mktemp ~/setuplog.XXXXXXXX) || exit 1

PYTHON_VERSION=3.10.6

setup