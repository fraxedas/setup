#!/usr/bin/env bash

set -euo pipefail

readonly NODE_VERSION="22"
readonly WORKSPACE_ROOT="${WORKSPACE_ROOT:-$HOME/GitHub}"

main() {
  print_step "Preparing macOS developer setup"

  ensure_xcode_command_line_tools
  ensure_homebrew

  print_step "Updating Homebrew"
  brew update

  install_command_line_tools
  install_node
  install_desktop_apps
  install_ai_tools
  install_playwright_browsers

  print_step "Upgrading installed Homebrew packages"
  brew upgrade

  print_step "Done"
  printf '%s\n' "Open a new terminal, then use: cd ~/GitHub/<repo>/web && npm ci && npm start"
}

print_step() {
  printf '\n==> %s\n' "$1"
}

add_line_once() {
  local file="$1"
  local line="$2"

  touch "$file"
  grep -Fqx "$line" "$file" || printf '%s\n' "$line" >> "$file"
}

ensure_xcode_command_line_tools() {
  local clt_label

  if xcode-select -p >/dev/null 2>&1; then
    return
  fi

  print_step "Installing Xcode Command Line Tools"
  clt_label="$(softwareupdate --list 2>&1 | sed -n 's/^[*] Label: //p' | grep 'Command Line Tools for Xcode' | tail -n 1 || true)"

  if [ -n "$clt_label" ]; then
    softwareupdate --install "$clt_label"
  else
    xcode-select --install || true
    printf '%s\n' "Finish the Command Line Tools installer, then rerun this script."
    exit 1
  fi

  xcode-select -p >/dev/null 2>&1 || {
    printf '%s\n' "Command Line Tools install started. Finish any macOS prompts, then rerun this script."
    exit 1
  }
}

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    print_step "Installing Homebrew"
    require_interactive_admin_for_homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  load_homebrew_shellenv
}

require_interactive_admin_for_homebrew() {
  if ! groups "$USER" | grep -qw admin; then
    printf '%s\n' "Homebrew requires an administrator account on macOS."
    exit 1
  fi

  if [ ! -t 0 ]; then
    printf '%s\n' "Homebrew needs an interactive sudo password prompt the first time it is installed."
    printf '%s\n' "Run this script from Terminal or install Homebrew first, then rerun it here."
    exit 1
  fi
}

load_homebrew_shellenv() {
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    add_line_once "$HOME/.zprofile" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
    add_line_once "$HOME/.zprofile" 'eval "$(/usr/local/bin/brew shellenv)"'
  fi
}

install_formula() {
  local formula="$1"

  if brew list --formula "$formula" >/dev/null 2>&1; then
    printf 'Already installed: %s\n' "$formula"
  else
    brew install "$formula"
  fi
}

install_cask() {
  local cask="$1"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    printf 'Already installed: %s\n' "$cask"
  else
    brew install --cask "$cask"
  fi
}

install_command_line_tools() {
  print_step "Installing command-line tools"
  install_formula git
  install_formula gh
  install_formula jq
  install_formula ripgrep
  install_formula azure-cli
  install_formula bicep
}

install_node() {
  print_step "Installing Node.js ${NODE_VERSION}"
  install_formula nvm

  export NVM_DIR="$HOME/.nvm"
  mkdir -p "$NVM_DIR"
  add_line_once "$HOME/.zshrc" 'export NVM_DIR="$HOME/.nvm"'
  add_line_once "$HOME/.zshrc" '[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"'

  # shellcheck disable=SC1091
  . "$(brew --prefix nvm)/nvm.sh"
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  nvm use "$NODE_VERSION"

  node --version
  npm --version
}

install_desktop_apps() {
  print_step "Installing desktop apps"
  install_cask visual-studio-code
  install_cask google-chrome
  install_cask firefox
  install_cask microsoft-azure-storage-explorer
}

install_ai_tools() {
  print_step "Installing AI-assisted development tools"
  install_cask github
  npm install -g @openai/codex

  install_vscode_extension GitHub.copilot
  install_vscode_extension GitHub.copilot-chat
  install_vscode_extension openai.chatgpt

  gh --version
  codex --version
}

install_vscode_extension() {
  local extension="$1"
  local code_bin="code"

  if ! command -v "$code_bin" >/dev/null 2>&1; then
    code_bin="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
  fi

  if [ ! -x "$code_bin" ]; then
    printf '%s\n' "Skipping VS Code extension ${extension}; VS Code command line tool is unavailable."
    return
  fi

  "$code_bin" --install-extension "$extension" --force
}

install_playwright_browsers() {
  local app_dir

  for app_dir in "$WORKSPACE_ROOT/score-keeper/web" "$WORKSPACE_ROOT/arcade-shooter/web"; do
    if [ -f "$app_dir/package.json" ] && [ -d "$app_dir/node_modules" ]; then
      print_step "Installing Playwright browsers for ${app_dir#$WORKSPACE_ROOT/}"
      (cd "$app_dir" && npx playwright install)
    elif [ -f "$app_dir/package.json" ]; then
      printf '%s\n' "Skipping Playwright browsers for ${app_dir#$WORKSPACE_ROOT/}; run npm ci there first."
    fi
  done
}

main "$@"
