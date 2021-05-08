{ config, pkgs, ...}:

let zshDotDir = ".config/zsh";
    zshDotDirAbs = "${config.home.homeDirectory}/${zshDotDir}";
    zkbdkeymap = "${zshDotDirAbs}/.zkbd/$TERM-\${\${DISPLAY:t}:-$VENDOR-$OSTYPE}";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    dotDir = zshDotDir;
    history = {
      extended = true;
      path = "${zshDotDirAbs}/history";
    };
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
      la = "ls -la";
      s = "sudo";
      c = "clear";
    };
    localVariables = { 
      LS_COLORS = builtins.readFile ./sh/LS_COLORS;
    };
    initExtraBeforeCompInit = ''
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors "''${(@s.:.)LS_COLORS}"
      zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
      zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**'
      zstyle :compinstall filename '${zshDotDir}/.zshrc'
    '';
    initExtra = ''
      if [[ -e "${zkbdkeymap}" ]]; then
        source "${zkbdkeymap}"
        [[ -n ''${key[Delete]} ]] && bindkey "''$key[Delete]" delete-char
        [[ -n ''${key[Home]} ]]   && bindkey "''$key[Home]"   beginning-of-line
        [[ -n ''${key[End]} ]]    && bindkey "''$key[End]"    end-of-line
        bindkey "^[[1;5C" emacs-forward-word    # Ctrl-Right
        bindkey "^[[1;5D" emacs-backward-word   # Ctrl-Left
        bindkey "^H"      backward-delete-word  # Ctrl-Backspace
        bindkey "^[[3;5~" delete-word           # Ctrl-Delete
      fi

      WORDCHARS=''${WORDCHARS/\/}

      # PROMPT description
      # [%F{green}%D{%H:%M}%f] - put the time between brackets in green
      # %F{yellow}%~%f         - current working directory in yellow
      # %(?.. %F{red}%?%f)     - status code of the last command if non-zero in red
      # %B%F{red}%n%f%b        - bold red username
      # %B%F{red}%m%f%b        - bold red hostname
      # %#                     - % or #
    
      PROMPT='
      [%F{green}%D{%H:%M}%f] %F{yellow}%~%f%(?.. %F{red}%?%f)
      %B%F{red}%n%f%b@%B%F{red}%m%f%b%# '

      man() {
        LESS_TERMCAP_md=$'\e[01;31m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[01;44;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[01;32m' \
        command man "$@"
      };

    '';

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zdharma";
          repo = "fast-syntax-highlighting";
          rev = "5351bd907ea39d9000b7bd60b5bb5b0b1d5c8046";
          sha256 = "0h7f27gz586xxw7cc0wyiv3bx0x3qih2wwh05ad85bh2h834ar8d";
        };
      }
    ];
  };
}
