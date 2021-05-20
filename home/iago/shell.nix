{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.shell;
in
{
  options.custom.shell = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    home.sessionVariables = mkIf cfg.enable {
      EDITOR = "vim";
      LS_COLORS = builtins.readFile ./sh/LS_COLORS;
      LSCOLORS = builtins.readFile ./sh/LSCOLORS;
    };
  };
}
