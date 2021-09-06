{ mod }:

{ module =
  { config, lib, pkgs, ... }:
  {
    xsession.windowManager.i3.config = {
      keybindings = lib.mkOptionDefault {
        "${mod}+Shift+e" = "exec --no-startup-id ${pkgs.qt5.qttools.bin}/bin/qdbus org.kde.ksmserver /KSMServer org.kde.KSMServerInterface.logout -1 -1 -1";
      };
      window.commands = [
        { criteria = { class = "systemsettings"; }; command = "floating enable"; }
        { criteria = { class = "plasmashell"; }; command = "floating enable;"; }
        { criteria = { class = "Plasma"; }; command = "floating enable; border none"; }
        { criteria = { class = "win7"; }; command = "floating enable; border none"; }
        { criteria = { class = "krunner"; }; command = "floating enable; border none"; }
        { criteria = { class = "Kmix"; }; command = "floating enable; border none"; }
        { criteria = { class = "Klipper"; }; command = "floating enable; border none"; }
        { criteria = { class = "Plasmoidviewer"; }; command = "floating enable; border none"; }
        { criteria = { class = "plasmashell"; window_type = "notification"; }; command = "border none, move right 700px, move down 450px"; }
        { criteria = { title = "Desktop — Plasma"; }; command = "kill; floating enable; border none"; }
      ];
    };
  };
  extraConfig = ''
    no_focus [class="plasmashell" window_type="notification"]
  '';
}
