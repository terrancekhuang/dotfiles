#!/usr/bin/env bash
# Bootstrap these dotfiles on Arch: packages, oh-my-zsh, tpm, then stow into $HOME.
# Conflicting files are moved to ~/.dotfiles-backup/<timestamp>/. Safe to re-run.
set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd -P)"
BAK="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Machine-specific bits that stay out of the install.
SKIP='(^|/)(settings\.local\.json|qbt-monitor|torrent-port-sync|[gs]et_torrent_port)$'

sudo pacman -S --needed --noconfirm \
  stow git curl zsh neovim kitty tmux starship eza bat zoxide fzf ripgrep fd wl-clipboard

"$DOT/.local/bin/omz-bootstrap"
[[ -d ~/.tmux/plugins/tpm ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Back up anything in the way that isn't already linked to the repo.
cd "$DOT"
while IFS= read -r -d '' f; do
  rel=${f#./}
  [[ $rel =~ $SKIP ]] && continue
  t="$HOME/$rel"
  [[ -e $t || -L $t ]] || continue
  [[ $(realpath -m "$t") == "$(realpath -m "$f")" ]] && continue
  mkdir -p "$BAK/$(dirname "$rel")"
  mv "$t" "$BAK/$rel"
  echo "backed up ~/$rel"
done < <(find . \( -name .git -o -name .gitignore -o -name .stow-local-ignore -o -name install.sh \) -prune \
  -o \( -type f -o -type l \) -print0)

stow -d "$(dirname "$DOT")" -t "$HOME" \
  --ignore='settings\.local\.json' --ignore='qbt-monitor' --ignore='torrent-port-sync' --ignore='[gs]et_torrent_port' \
  "$(basename "$DOT")"

[[ $SHELL == */zsh ]] || chsh -s "$(command -v zsh)"
echo "done. backups (if any): $BAK"
