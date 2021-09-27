if [[ -e "@zkbdkeymap@" ]]; then
  source "@zkbdkeymap@"
else
  autoload zkbd
  echo "Could not load keymap. Run zkbd to create one."
fi

[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char
[[ -n ${key[Home]}   ]] && bindkey "${key[Home]}"   beginning-of-line
[[ -n ${key[End]}    ]] && bindkey "${key[End]}"    end-of-line
[[ -n ${key[Up]}     ]] && bindkey "${key[Up]}"     history-beginning-search-backward
[[ -n ${key[Down]}   ]] && bindkey "${key[Down]}"   history-beginning-search-forward

bindkey "^[[1;5C" emacs-forward-word    # Ctrl-Right
bindkey "^[[1;5D" emacs-backward-word   # Ctrl-Left
bindkey "^[[1;2C" emacs-forward-word    # Shift-Right
bindkey "^[[1;2D" emacs-backward-word   # Shift-Left
bindkey "^H"      backward-delete-word  # Ctrl-Backspace
bindkey "^[[3;5~" delete-word           # Ctrl-Delete

WORDCHARS=${WORDCHARS/\/}

# PROMPT description
# [%F{green}%D{%H:%M}%f] - put the time between brackets in green
# %F{yellow}%~%f         - current working directory in yellow
# %{$([ -z ${DIRENV_DIR+x} ] || { echo -n " %B(direnv)%b"; echo -n "%9G" })%} - very convoluted way to test for a direnv variable
#                                                                               - to correctly print "(direnv)"
# %(?.. %F{red}%?%f)     - status code of the last command if non-zero in red
# %B%F{red}%n%f%b        - bold red username
# %B%F{red}%m%f%b        - bold red hostname
# %#                     - % or #

# enables command substitution inside the prompt string
setopt promptsubst

PROMPT='
[%F{green}%D{%H:%M}%f] %F{yellow}%~%{$([ -z ${DIRENV_DIR+x} ] || { echo -n " %B(direnv)%b"; echo -n "%9G" })%}%(?.. %F{red}%?)%f
%B%F{red}%n%f%b@%B%F{red}%m%f%b%# '

man() {
  LESS_TERMCAP_md=$'\e[01;31m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[01;44;33m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[01;32m' \
  command man "$@"
}

flakify() {
  template=${1:-generic}
  nix flake new -t "github:iagocq/nix#$template" .
  direnv allow
  ${EDITOR:-vim} flake.nix
}
