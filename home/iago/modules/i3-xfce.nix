{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.i3-xfce;
in
{
  imports = [ ./i3.nix ./gtk.nix ];

  options.custom.i3-xfce = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    custom.i3.enable = cfg.enable;
    custom.gtk.enable = cfg.enable;

    xsession.windowManager.i3.config = mkIf cfg.enable {
      keybindings = lib.mkOptionDefault {
        "${config.custom.i3.mod}+Shift+e" = "exec --no-startup-id xfce4-session-logout";
      };
      window.commands = [
        { criteria = { class = "Thunar"; }; command = "floating enable"; }
      ];
    };
  };
}
