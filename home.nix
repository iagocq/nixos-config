{ config, pkgs, ... }:

let cfgImports = [
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
    nixos-stable = import <nixos-stable> {}; in
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
    youtube-dl ffmpeg-full calc git scrot
    neofetch maim streamlink zip unzip
    gdb valgrind
    rr
    vulkan-tools vulkan-loader
    ntfs3g
    lilv
    tmux
    imagemagick
    unrar
    innoextract
    gnupg
    man-pages posix_man_pages
    # clinfo cudaPackages.cudatoolkit_10_1

    # jack2
    rnnoise-plugin x42-plugins
    xorg.xmodmap xorg.xev

    # Build utils
    binutils gcc cmake gnumake

    python3 pipenv poetry

    calf
    
    (texlive.combine { inherit (texlive) scheme-medium abntex2 enumitem lastpage microtype adjustbox collectbox; })
    
    real_time_config_quick_scan

    pulseaudio

    monero monero-gui xmr-stak xmrig

    android-studio apktool dex2jar jd-gui

    avahi-compat pkgconfig

    tcpdump
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    LS_COLORS = builtins.readFile ./sh/LS_COLORS;
    LSCOLORS = builtins.readFile ./sh/LSCOLORS;
  };

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

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
