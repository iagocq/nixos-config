{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.i3;
  rofi-plugins = with pkgs; rofi.override { plugins = [ ]; };
  mkColors = border: background: text: indicator: childBorder: { inherit background border childBorder indicator text; };
  orange-1 = "#E6840E";
  orange-2 = "#BA741E";
  brown-1 = "#995605";
  black-1 = "#0D0D0D";
  black-2 = "#5f676a";
  white-1 = "#FFFFFF";
  gray-1 = "#666666";
  gray-2 = "#888888";
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

    polybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
      };
    };
  };

  config = mkIf cfg.enable {

    xsession.windowManager.i3 = {
      enable = true;

      config = {
        modifier = cfg.mod;
        menu = "${cfg.menu}";
        terminal = "${config.custom.terminal.cmd}";

        window.commands = [
          { criteria = { window_role = "pop-up"; }; command = "floating enable"; }
          { criteria = { window_role = "task_dialog"; }; command = "floating enable"; }
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

        window.border = 1;
        floating.border = 1;

        colors.focused         = mkColors orange-1 black-1 white-1 orange-1 orange-1;
        colors.focusedInactive = mkColors orange-2 black-1 white-1 orange-2 orange-2;
        colors.unfocused       = mkColors brown-1 black-1 white-1 brown-1 brown-1;

        bars = [{
          mode = "dock";
          hiddenState = "hide";
          position = "bottom";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = {
            names = [ "monospace" ];
            size = 8.0;
          };
          trayOutput = "primary";
          colors = {
            background = black-1;
            statusline = white-1;
            separator = gray-1;
            focusedWorkspace = { border = brown-1; background = orange-2; text = white-1; };
            activeWorkspace = { border = orange-2; background = black-2; text = gray-2; };
          };
        }];

        workspaceAutoBackAndForth = false;
      };

      extraConfig = ''
        exec i3-msg workspace number ${cfg.start-ws}
      '';
    };

    home.file.".icons/default".source = "${pkgs.capitaine-cursors}/share/icons/capitaine-cursors";
  };
}
