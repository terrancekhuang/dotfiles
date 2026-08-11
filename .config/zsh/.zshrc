# ============================================================================
# zshrc
# ============================================================================

# ============================================================================
# Editor Configuration
# ============================================================================
export EDITOR=nvim

# ============================================================================
# Shell Behavior
# ============================================================================
# Vim keybindings
bindkey -v

# Lower key timeout for faster mode switching
KEYTIMEOUT=1

# Uncomment to prevent searching for commands not found in package manager
# unset -f command_not_found_handler

# ============================================================================
# Plugin Integrations
# ============================================================================

# Zoxide (better cd)
# Regenerate cache if missing or older than the binary
zoxide_cache="$HOME/.cache/zsh/zoxide.zsh"
if [[ ! -f "$zoxide_cache" || "$(command -v zoxide)" -nt "$zoxide_cache" ]]; then
  mkdir -p "$(dirname "$zoxide_cache")"
  zoxide init zsh > "$zoxide_cache"
fi
source "$zoxide_cache"

# fzf integration
fzf_cache="$HOME/.cache/zsh/fzf.zsh"
if [[ ! -f "$fzf_cache" || "$(command -v fzf)" -nt "$fzf_cache" ]]; then
  mkdir -p "$(dirname "$fzf_cache")"
  fzf --zsh > "$fzf_cache"
fi
source "$fzf_cache"

# ============================================================================
# System & Package Management Aliases
# ============================================================================
alias un='$aurhelper -Rns'                                  # uninstall package
alias up='$aurhelper -Syu'                                  # update system/package/aur
alias pl='$aurhelper -Qs'                                   # list installed package
alias pa='$aurhelper -Ss'                                   # list available package
alias pc='$aurhelper -Sc'                                   # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -'             # remove unused packages

# Interactive yay using fzf
alias iyay="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"

# Interactive git add
gadd() {
  git ls-files --modified --others --exclude-standard -z \
    | fzf -m --read0 --print0 \
    | xargs -0 git add
}

# ============================================================================
# File & Directory Aliases
# ============================================================================
# Basic commands
alias c='clear'                                             # clear terminal
alias cat='bat'                                             # better cat with syntax highlighting
alias vim='nvim'                                            # use neovim

# Directory listing (eza)
alias l='eza -1 --icons=auto'                               # short list
alias ls='eza -lh --icons=auto'                             # long list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto'                            # long list dirs
alias lt='eza --icons=auto --tree'                          # list folder as tree

# Directory navigation
alias cd='z'                                                # use zoxide instead of cd
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Safety aliases
alias rm='rm -i'                                            # don't do anything stupid

# Set brightness
setbrightness() {
    local brightness=$1
    if [[ $brightness -gt 100 ]]; then
        brightness=100
    elif [[ $brightness -lt 1 ]]; then
        brightness=1
    fi
    ddcutil --terse setvcp 10 $brightness > /dev/null 2>&1
}

# ============================================================================
# Application Aliases
# ============================================================================
alias vc='code'                                             # VS Code

# Open apps detached
vlc() { command vlc "$@" &>/dev/null & disown; }
mpv() { command mpv "$@" &>/dev/null & disown; }
zathura() { command zathura "$@" &>/dev/null & disown; }
libreoffice() { command libreoffice "$@" &>/dev/null & disown; }
loupe() { command loupe "$@" &>/dev/null & disown; }
darktable() { command darktable "$@" &>/dev/null & disown; }
okular() { command okular "$@" &>/dev/null & disown; }
xournalpp() { command xournalpp "$@" &>/dev/null & disown; }

# ============================================================================
# Clipboard Management
# ============================================================================
alias ccb='wl-copy --clear && wl-copy --clear --primary'    # clear clipboard

# ============================================================================
# SSH Agent
# ============================================================================
# Start ssh agent automatically
if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
  if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
  fi
  source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

export PATH="$HOME/.local/bin/verse:$PATH"

# Node NVM lazy load
export NVM_DIR="$HOME/.nvm"

nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  nvm "$@"
}
