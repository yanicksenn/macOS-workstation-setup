#!/usr/bin/env zsh

# Installation script containing all sdks and tools to my
# personal liking. Feel free to fork and modify this file.

# Single-line invocation:
# /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/yanicksenn/setup/main/macOS/install.sh)"


# Utilities

# Hard-copy these utility functions into this file so it
# can be invoked with a single curl line.

log() {
  echo "$1" | tee -a "$LOGFILE"
}

confirm() {
  local message=$1

  # read -r -p "$message [y/N]: " response
  read -r "response?$message [y/N]: "
  case "$response" in
      [yY][eE][sS]|[yY])
          true
          ;;
      *)
          false
          ;;
  esac
}


VERSION=1.0.0
LOGFILE=$(mktemp ~/install-$VERSION.log.XXXXXXXX) || exit 1

PYTHON_VERSION=3.10.6
JAVA_VERSION=17.0.2-open


log "Setup workspace - macOS"
log "  Version: $VERSION"
log "  Logfile: $LOGFILE"
log ""

if ! confirm "Do you want to continue?"; then
  log "User abort"
  exit 1
fi
log ""


log "Installing prerequisites ..."

log "  Installing xcode ..."
xcode-select --install >> "$LOGFILE"

log "  Installing brew ..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >> "$LOGFILE"


log "Installing Python & Tools ..."

log "  Installing pyenv ..."
brew install pyenv >> "$LOGFILE"

log "  Installing pyenv-update ..."
git clone https://github.com/pyenv/pyenv-update.git "$path" >> "$LOGFILE"

log "  Installing python $PYTHON_VERSION ..."
pyenv install -s "$PYTHON_VERSION" >> "$LOGFILE"


log "Installing JDK & JVM Tools ..."

log "  Installing sdkman ..."
curl -s "https://get.sdkman.io" | bash >> "$LOGFILE"
source "$HOME/.sdkman/bin/sdkman-init.sh"

log "  Installing java $JAVA_VERSION ..."
sdk install java "$JAVA_VERSION" >> "$LOGFILE"

log "  Installing kotlin ..."
sdk install kotlin >> "$LOGFILE"

log "  Installing maven ..."
sdk install maven >> "$LOGFILE"

log "  Installing gradle ..."
sdk install gradle >> "$LOGFILE"


log "Installing Tools ..."

log "  Installing jetbrains-toolbox ..."
brew install --cask jetbrains-toolbox >> "$LOGFILE"

log "  Installing visual-studio-code ..."
brew install --cask visual-studio-code >> "$LOGFILE"

log "  Installing cyberduck ..."
brew install --cask cyberduck >> "$LOGFILE"

log "  Installing docker ..."
brew install --cask docker >> "$LOGFILE"

log "  Installing google-chrome ..."
brew install --cask google-chrome >> "$LOGFILE"

log "  Installing grammarly-desktop ..."
brew install --cask grammarly-desktop >> "$LOGFILE"

log "  Installing 1password ..."
brew install --cask 1password >> "$LOGFILE"

log "  Installing 1password-cli ..."
brew install --cask 1password-cli >> "$LOGFILE"

log ""


log "Setup done."