{ config, lib, pkgs, ... }:

let mod = "Mod4";
    i3-dm = import ./i3-xfce.nix { inherit mod; };
    rofi-plugins = with pkgs; rofi.override { plugins = [ ]; };
    alacritty-cmd = "${pkgs.alacritty}/bin/alacritty";
    home-dir = "${config.home.homeDirectory}";
    im-ws = "5"; 
    web-ws = "1"; 
    audio-ws = "6"; in
{
  imports = [ i3-dm.module ./picom.nix ];

  #home.file."Pictures/wallpapers/current-wallpaper".source = "${home-dir}/Pictures/wallpapers/terraria-dark-2560x1080.png";

  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;
      menu = "${rofi-plugins}/bin/rofi -show drun -show-icons";
      terminal = "${alacritty-cmd}";

      window.commands = [
        { criteria = { window_role = "pop-up"; }; command = "floating enable"; }
        { criteria = { window_role = "task_dialog"; }; command = "floating enable"; }
        { criteria = { class = ".*"; }; command = "border pixel 2"; }
        { criteria = { class = "chatterino"; title = ".*'s Usercard"; }; command = "floating enable"; }
        { criteria = { class = "chatterino"; title = "Searching in .* history"; }; command = "floating enable"; }
        { criteria = { class = "Firefox"; }; command = "move to workspace number ${web-ws}"; }
        { criteria = { class = "discord"; }; command = "move to workspace number ${im-ws}"; }
        { criteria = { class = "Ripcord"; }; command = "move to workspace number ${im-ws}"; }
        { criteria = { class = "Ripcord"; title = "Ripcord Voice Chat"; }; command = "floating enable"; }
        { criteria = { class = "TelegramDesktop"; }; command = "move to workspace number ${im-ws}"; }
        { criteria = { class = "TelegramDesktop"; title = "Media viewer"; }; command = "fullscreen disable; floating enable; resize set 2560 1080; move position 0 0"; }
        { criteria = { class = "mpv"; }; command = "fullscreen enable;"; }
        { criteria = { class = "QjackCtl"; }; command = "floating enable; move to workspace number ${audio-ws}"; }
        { criteria = { class = "Carla2"; }; command = "move to workspace number ${audio-ws}"; }
      ];

      keybindings = lib.mkOptionDefault {
        "Shift+Print" = "exec ${./sh/screenshot.sh} region";
        "Print" = "exec ${./sh/screenshot.sh} full";
        "Ctrl+Print" = "exec ${./sh/screenshot.sh} window";
      };

      startup = [
        { command = "${./sh/login.sh}"; notification = false; }
        { command = "${pkgs.feh}/bin/feh --no-fehbg --bg-fill $HOME/Pictures/wallpapers/current-wallpaper"; always = true; notification = false; }
      ];

      gaps.inner = 10;
      gaps.smartGaps = true;
      gaps.smartBorders = "on";
    };

    extraConfig = ''
      exec i3-msg workspace number 4
      workspace_auto_back_and_forth no
    '' + i3-dm.extraConfig;
  };

  programs.rofi = {
    enable = true;
    package = rofi-plugins;
    terminal = "${alacritty-cmd}";
    location = "top";
    theme = "Arc-Dark";
  };

  home.packages = with pkgs; [ maim feh xdotool xclip ];
  home.file.".icons/default".source = "${pkgs.capitaine-cursors}/share/icons/capitaine-cursors";
}
