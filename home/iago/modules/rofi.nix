{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.rofi;
in
{
  options.custom.rofi = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    package = mkOption {
      type = types.package;
      default = pkgs.rofi;
    };

    cmd = mkOption {
      type = types.str;
      default = "${cfg.package}/bin/rofi -show drun -show-icons";
    };
  };

  config = {
    programs.rofi = mkIf cfg.enable {
      enable = true;
      package = cfg.package;
      terminal = config.custom.terminal.cmd;
      location = "top";
      theme = "Arc-Dark";
    };
  };
}     
