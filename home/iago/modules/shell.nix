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

    nix-index = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "vim";
      LS_COLORS = builtins.readFile ./sh/LS_COLORS;
      LSCOLORS = builtins.readFile ./sh/LSCOLORS;
    };

    programs.nix-index.enable = cfg.nix-index;
  };
}
