{ mod }:

{ module =
  { config, lib, pkgs, ... }:
  {
    imports = [ ./gtk.nix ];
    xsession.windowManager.i3.config = {
      keybindings = lib.mkOptionDefault {
        "${mod}+Shift+e" = "exec --no-startup-id xfce4-session-logout";
      };
      window.commands = [ ];
    };
  };
  extraConfig = ''
  '';
}
