# ============================================================================
# zshrc
# ============================================================================

# ============================================================================
# Oh My Zsh (install with omz-bootstrap)
# ============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                                                # prompt is starship
plugins=(git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
[[ -r $ZSH/oh-my-zsh.sh ]] && source "$ZSH/oh-my-zsh.sh"    # must precede bindkey/aliases below

export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
command -v starship &>/dev/null && eval "$(starship init zsh)"

setopt INTERACTIVE_COMMENTS

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

# Ctrl/Alt-arrow word jumps, Delete key
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[5C" forward-word
bindkey "^[[5D" backward-word
bindkey "^[OC" forward-word
bindkey "^[OD" backward-word
bindkey "^[[3~" delete-char

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

# Interactive yay using fzf
alias iyay="yay -Slq | fzf --multi --preview 'yay -Si {1}' | xargs -ro yay -S"

# fzf git add
gaf() {
  git status --porcelain=v1 \
    | fzf -m --preview 'f=$(echo {} | cut -c4- | sed -e "s/^\"//" -e "s/\"$//"); git diff --color=always -- "$f"' \
    | cut -c4- \
    | sed -e 's/^"//' -e 's/"$//' \
    | while IFS= read -r f; do git add -- "$f"; done
}

# ============================================================================
# File & Directory Aliases
# ============================================================================
# Basic commands
alias cat='bat'                                             # better cat with syntax highlighting
alias vim='nvim'                                            # use neovim

# Directory listing (eza)
alias l='eza -1 --icons=auto'                               # short list
alias ls='eza -lh --icons=auto'                             # long list
alias la='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
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
# Open apps detached
vlc() { command vlc "$@" &>/dev/null & disown; }
mpv() { command mpv "$@" &>/dev/null & disown; }
zathura() { command zathura "$@" &>/dev/null & disown; }
libreoffice() { command libreoffice "$@" &>/dev/null & disown; }
loupe() { command loupe "$@" &>/dev/null & disown; }
darktable() { command darktable "$@" &>/dev/null & disown; }
okular() { command okular "$@" &>/dev/null & disown; }
xournalpp() { command xournalpp "$@" &>/dev/null & disown; }

# Betterbird
alias betterbird='GDK_BACKEND=x11 betterbird'

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
