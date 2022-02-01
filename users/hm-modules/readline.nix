{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.readline;
in
{
  options.custom.readline = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    programs.readline = mkIf cfg.enable {
      enable = true;
      extraConfig = ''
        set colored-stats on
      '';
    };
  };
}
