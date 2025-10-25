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
eval "$(zoxide init zsh)"

# fzf integration
source <(fzf --zsh)

# ============================================================================
# System & Package Management Aliases
# ============================================================================
alias un='$aurhelper -Rns'                                  # uninstall package
alias up='$aurhelper -Syu'                                  # update system/package/aur
alias pl='$aurhelper -Qs'                                   # list installed package
alias pa='$aurhelper -Ss'                                   # list available package
alias pc='$aurhelper -Sc'                                   # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -'             # remove unused packages

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

# ============================================================================
# Application Aliases
# ============================================================================
alias vc='code'                                             # VS Code

# VLC with no terminal output
vlc() {
    /usr/bin/vlc "$@" &>/dev/null & disown
}

# ============================================================================
# Clipboard Management
# ============================================================================
alias ccb='wl-copy < /dev/null'                             # clear clipboard

# ============================================================================
# Session Management
# ============================================================================
# Attach tmux on startup
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t main || tmux new-session -s main
fi

# ============================================================================
# SSH Agent
# ============================================================================
# Start ssh agent automatically
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [ ! -f "$SSH_AUTH_SOCK" ]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi
