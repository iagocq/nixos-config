{ config, lib, pkgs, ...}:

with lib;

let
  cfg = config.custom.direnv;
in
{
  options.custom.direnv = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    programs.direnv = mkIf cfg.enable {
      enable = true;
      nix-direnv.enable = true;
      stdlib = ''
		: ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
          echo "''${direnv_layout_dirs[$PWD]:=$(
            echo -n "$XDG_CACHE_HOME"/direnv/layouts/
            echo -n "$PWD" | shasum | cut -d ' ' -f 1
          )}"
        }
      '';
    };
  };
}
