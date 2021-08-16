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
      nix-direnv = {
        enable = true;
        enableFlakes = true;
      };
    };
  };
}
