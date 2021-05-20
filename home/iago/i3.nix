{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.i3;
  rofi-plugins = with pkgs; rofi.override { plugins = [ ]; };
in
{
  options.custom.i3 = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    mod = mkOption {
      type = types.str;
      default = "Mod4";
    };

    im-ws = mkOption {
      type = types.str;
      default = "5";
    };

    web-ws = mkOption {
      type = types.str;
      default = "1";
    };

    audio-ws = mkOption {
      type = types.str;
      default = "6";
    };

    start-ws = mkOption {
      type = types.str;
      default = "1";
    };

    login = mkOption {
      type = types.str;
      default = "";
    };

    wallpaper = mkOption {
      type = types.str;
      default = "${config.home.homeDirectory}/Pictures/wallpapers/current-wallpaper";
    };

    screenshot = mkOption {
      type = types.str;
      default = "";
    };

    menu = mkOption {
      type = types.str;
      default = "${pkgs.dmenu}/bin/dmenu";
    };
  };

  config = {

    xsession.windowManager.i3 = mkIf cfg.enable {
      enable = true;

      config = {
        modifier = cfg.mod;
        menu = "${cfg.menu}";
        terminal = "${config.custom.terminal.cmd}";

        window.commands = [
          { criteria = { window_role = "pop-up"; }; command = "floating enable"; }
          { criteria = { window_role = "task_dialog"; }; command = "floating enable"; }
          { criteria = { class = ".*"; }; command = "border pixel 2"; }
          { criteria = { class = "chatterino"; title = ".*'s Usercard"; }; command = "floating enable"; }
          { criteria = { class = "chatterino"; title = "Searching in .* history"; }; command = "floating enable"; }
          { criteria = { class = "Firefox"; }; command = "move to workspace number ${cfg.web-ws}"; }
          { criteria = { class = "discord"; }; command = "move to workspace number ${cfg.im-ws}"; }
          { criteria = { class = "Ripcord"; }; command = "move to workspace number ${cfg.im-ws}"; }
          { criteria = { class = "Ripcord"; title = "Ripcord Voice Chat"; }; command = "floating enable"; }
          { criteria = { class = "TelegramDesktop"; }; command = "move to workspace number ${cfg.im-ws}"; }
          { criteria = { class = "TelegramDesktop"; title = "Media viewer"; }; command = "fullscreen disable; floating enable; resize set 2560 1080; move position 0 0"; }
          { criteria = { class = "mpv"; }; command = "fullscreen enable;"; }
          { criteria = { class = "QjackCtl"; }; command = "floating enable; move to workspace number ${cfg.audio-ws}"; }
          { criteria = { class = "Carla2"; }; command = "move to workspace number ${cfg.audio-ws}"; }
        ];

        keybindings = mkIf (cfg.screenshot != "") (lib.mkOptionDefault {
          "Shift+Print" = "exec ${cfg.screenshot} region";
          "Print" = "exec ${cfg.screenshot} full";
          "Ctrl+Print" = "exec ${cfg.screenshot} window";
        });

        startup = [
          (mkIf (cfg.login != "") { command = "${cfg.login}"; notification = false; })
          { command = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill ${cfg.wallpaper}"; always = true; notification = false; }
        ];

        gaps.inner = 10;
        gaps.smartGaps = true;
        gaps.smartBorders = "on";
      };

      extraConfig = ''
        exec i3-msg workspace number ${cfg.start-ws}
        workspace_auto_back_and_forth no
      '';
    };

    home.file.".icons/default".source = "${pkgs.capitaine-cursors}/share/icons/capitaine-cursors";
  };
}
