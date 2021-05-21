{ config, pkgs, ... }:

{
  imports = [
    ./modules.nix
  ];

  home.packages = with pkgs; [
    calc git
    neofetch streamlink
    zip unzip p7zip unar atool
    gnupg
    man-pages posix_man_pages
    screen
    nnn
    git-crypt
  ];

  home.sessionVariables = {
    NNN_OPENER = "${pkgs.nnn-src}/plugins/nuke";
  };

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
