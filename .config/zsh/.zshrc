# Add user configurations here
# For HyDE to not touch your beloved configurations,
# we added a config file for you to customize HyDE before loading zshrc
# Edit $ZDOTDIR/.user.zsh to customize HyDE before loading zshrc

#  Plugins 
# oh-my-zsh plugins are loaded  in $ZDOTDIR/.user.zsh file, see the file for more information

#  Aliases 
# Override aliases here in '$ZDOTDIR/.zshrc' (already set in .zshenv)

# Helpful aliases
alias c='clear'                                                        # clear terminal
alias l='eza -1 --icons=auto'                                          # short list
alias ls='eza -lh --icons=auto'                                        # long list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto'                                       # long list dirs
alias lt='eza --icons=auto --tree'                                     # list folder as tree
alias un='$aurhelper -Rns'                                             # uninstall package
alias up='$aurhelper -Syu'                                             # update system/package/aur
alias pl='$aurhelper -Qs'                                              # list installed package
alias pa='$aurhelper -Ss'                                              # list available package
alias pc='$aurhelper -Sc'                                              # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -'                        # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code'                                                        # gui code editor
# alias fastfetch='fastfetch --logo-type kitty'

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# # Always mkdir a path (this doesn't inhibit functionality to make a single dir)
# alias mkdir='mkdir -p'

# don't do anything stupid
alias rm='rm -i'

alias cat='bat'

#  This is your file 
# Add your configurations here
export EDITOR=nvim
# export EDITOR=code

# unset -f command_not_found_handler # Uncomment to prevent searching for commands not found in package manager

alias vim=nvim
# Vim keybindings
bindkey -v

# lower key timeout
KEYTIMEOUT=1

# vlc no terminal output
vlc() {
    /usr/bin/vlc "$@" &>/dev/null & disown
}

# Zoxide
eval "$(zoxide init zsh)"
alias cd=z

# Clear clipboard
alias ccb='wl-copy < /dev/null'

# Attach tmux on startup 
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux attach-session -t main || tmux new-session -s main
fi

# start ssh agent automatically
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [ ! -f "$SSH_AUTH_SOCK" ]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# fzf integration
source <(fzf --zsh)
