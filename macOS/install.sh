#!/usr/bin/env bash

# Installation script containing all sdks and tools to my
# personal liking. Feel free to fork and modify this file.

# Single-line invocation:
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yanicksenn/setup/main/macOS/setup.sh)"


# Utilities

# Hard-copy these utility functions into this file so it
# can be invoked with a single curl line.

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


# Installation of xcode

install_prereq_xcode() {
  if ! xcode-select -p &> /dev/null; then
    log "  Installing xcode ..."
    xcode-select --install >> "$LOGFILE"
    log "  xcode installed"
  else
    log "  xcode already installed"
  fi
}


# Installation & usage of brew

install_prereq_brew() {
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


# Installation & usage of sdkman

install_sdkman() {
  if ! command_exists "sdk"; then
    log "  Installing sdkman ..."
    curl -s "https://get.sdkman.io" | bash >> "$LOGFILE"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    log "  sdkman installed"
  else
    log "  sdkman already installed"
  fi
}

sdk_install() {
  local name=$1
  local version=$2

  local candidate=~/.sdkman/candidates/$name/$version

  if [ ! -d "$candidate" ]; then
    log "  Installing $name $version ..."
    sdk_install "$name" "$version" >> "$LOGFILE"
    log "  $name $version installed"
  else
    log "  $name $version already installed"
  fi
}


# Installation & usage of pyenv

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

pyenv_install() {
  local version=$1

  if ! pyenv versions --bare | grep -q "$version"; then
    log "  Installing python $version ..."
    pyenv install -s "$version" >> "$LOGFILE"
    log "  python $version installed"
  else
    log "  python $version already installed"
  fi
}


# Main installation

install() {
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
  install_prereq_xcode
  install_prereq_brew
  log ""

  # Install Python & Tools
  log "Installing Python & Tools ..."
  install_pyenv
  install_pyenv_update
  pyenv_install "$PYTHON_VERSION"
  log ""

  # Install JDK & JVM Tools
  log "Installing JDK & JVM Tools ..."
  install_sdkman
  sdk_install "$JAVA_VERSION"
  sdk_install kotlin
  sdk_install maven
  sdk_install gradle
  log ""

  # Install tools
  log "Installing tools ..."
  brew_install_cask jetbrains-toolbox
  brew_install_cask visual-studio-code
  brew_install_cask cyberduck
  brew_install_cask docker
  brew_install_cask google-chrome
  brew_install_cask grammarly-desktop
  brew_install_cask 1password
  brew_install_cask 1password-cli
  log ""

  log "Setup done."
}

VERSION=1.0.0
LOGFILE=$(mktemp ~/install.log.XXXXXXXX) || exit 1

PYTHON_VERSION=3.10.6
JAVA_VERSION=17.0.2-open

install