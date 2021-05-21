{ config, pkgs, ... }:

{
  imports = [
    ./modules.nix
  ];

  home.packages = with pkgs; [
    # Desktop applications
    tdesktop discord qbittorrent vlc mpv
    obs-studio logisim feh chatterino2
    lutris steam qjackctl pavucontrol
    carla
    ungoogled-chromium
    multimc ripcord

    # Command line applications
    youtube-dl ffmpeg-full calc git
    neofetch streamlink
    gdb valgrind rr
    vulkan-tools vulkan-loader
    ntfs3g
    tmux
    imagemagick
    zip unzip p7zip unar atool innoextract
    gnupg
    man-pages posix_man_pages
    screen
    python3
    tcpdump
    nnn

    (texlive.combine { inherit (texlive) scheme-medium abntex2 enumitem lastpage microtype adjustbox collectbox; })

    pulseaudio
    
    # Java and Android things
    adoptopenjdk-hotspot-bin-8
    android-studio apktool dex2jar jd-gui

    (import ./vscode-with-exts.nix { pkg = pkgs.vscodium; inherit pkgs; } )

    calf rnnoise-plugin x42-plugins
  ];

  home.sessionVariables = {
    NNN_OPENER = "${pkgs.nnn-src}/plugins/nuke";
  };

  custom.alacritty.enable = true;
  custom.terminal.cmd = config.custom.alacritty.cmd;
  custom.rofi.enable = true;
  custom.i3-xfce.enable = true;
  custom.i3 = {
    menu = config.custom.rofi.cmd;
    screenshot = builtins.replaceStrings [ "\\\n" ] [ "" ] ''
      maim=${pkgs.maim}/bin/maim \
      feh=${pkgs.feh}/bin/feh \
      xdotool=${pkgs.xdotool}/bin/xdotool \
      xclip=${pkgs.xclip}/bin/xclip \
      ${./sh/screenshot.sh} \
    '';
    login = "${./sh/login.sh}";
  };
  custom.picom.enable = true;
  custom.mpv.enable = true;
  custom.readline.enable = true;
  custom.streamlink.enable = true;
  custom.vim.enable = true;
  custom.shell.enable = true;
  custom.zsh.enable = true;
  custom.zsh.plugins = [
    {
      name = "fast-syntax-highlighting";
      src = pkgs.zsh-f-sy-h.outPath;
    }
  ];

  programs.firefox = {
    enable = true;
    profiles.iago = {
      isDefault = true;
      userChrome = builtins.readFile ./firefox/userChrome.css;
    };
  };

  home.username = "iago";
  home.homeDirectory = "/home/iago-nixos";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";
}
