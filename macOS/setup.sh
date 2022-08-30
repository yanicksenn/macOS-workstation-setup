#!/usr/bin/env bash

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

install_xcode() {
  if ! xcode-select -p &> /dev/null; then
    xcode-select --install
  else
    echo "xcode already installed"
  fi
}

install_brew() {
  if ! command_exists "brew"; then
     /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "brew already installed"
  fi
}

install_sdkman() {
  if ! command_exists "sdk"; then
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  else
    echo "sdkman already installed"
  fi
}

VERSION=1.0.0

echo "Setup workspace - macOS"
echo "  Version: $VERSION"
echo ""

if ! confirm "Do you want to continue?"; then
  echo "User abort"
  exit 1
fi

# Install prerequisites
install_xcode
install_brew
install_sdkman

# Install Python
brew install python@3.10

# Install JDK and JVM Tools
sdk install java 17.0.2-open
sdk install kotlin
sdk install maven
sdk install gradle

# Install dev-tools
brew install --cask jetbrains-toolbox
brew install --cask visual-studio-code
brew install --cask cyberduck

# Install utilities
brew install --cask google-chrome
brew install --cask grammarly-desktop
brew install --cask 1password

echo ""
echo "Setup done."
