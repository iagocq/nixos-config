{ config, pkgs, ... }:

let
  cfgImports = [
    ./alacritty.nix
    #./audio.nix
    ./firefox.nix
    ./i3.nix
    ./mpv.nix
    ./readline.nix
    ./streamlink.nix
    ./vim.nix
    ./vscode.nix
    ./zsh.nix
  ];
  #audio-plugins = with pkgs; [ rnnoise-plugin x42-plugins calf ];
in
{
  imports = cfgImports;

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
    neofetch maim streamlink
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
  ];
  #++ audio-plugins;

  home.sessionVariables = {
    EDITOR = "vim";
    LS_COLORS = builtins.readFile ./sh/LS_COLORS;
    LSCOLORS = builtins.readFile ./sh/LSCOLORS;
    NNN_OPENER = "${config.xdg.configHome}/nnn/plugins/nuke";
  };

  #nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  #programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
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
