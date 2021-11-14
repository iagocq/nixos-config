{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.custom.zsh;
  zsh-dot-dir-abs = "${cfg.base}/${cfg.dot-dir}";
  zkbdkeymap = "${zsh-dot-dir-abs}/.zkbd/$TERM-\${\${DISPLAY:t}:-$VENDOR-$OSTYPE}";
in
{
  options.custom.zsh = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    dot-dir = mkOption {
      type = types.str;
      default = ".config/zsh";
    };

    base = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}";
    };

    plugins = mkOption {
      type = types.anything;
      default = [ ];
    };

    nix-index = mkOption {
      type = types.bool;
      default = config.custom.shell.nix-index;
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = false;
      dotDir = cfg.dot-dir;

      history = {
        extended = true;
        path = "${zsh-dot-dir-abs}/history";
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

      initExtraBeforeCompInit =
        let
          initExtraBefore = pkgs.substituteAll {
            name = "init-extra-before-comp-init-zsh";
            src = ./sh/init-extra-before-comp-init.zsh;
            inherit (cfg) dot-dir;
          };
        in "source ${initExtraBefore}";

      initExtra =
        let
          initExtra = pkgs.substituteAll {
            name = "init-extra-zsh";
            src = ./sh/init-extra.zsh;
            inherit zkbdkeymap;
          };
        in "source ${initExtra}";

      plugins = cfg.plugins;
    };

    programs.nix-index.enableZshIntegration = cfg.nix-index;
  };
}
