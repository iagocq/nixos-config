{ config, lib, pkgs, host, ... }:

{
  imports = [
    (./. + "/${host}")
  ];

  home.packages = with pkgs; [
    calc git git-crypt
    neofetch
    zip unzip p7zip atool
    man-pages posix_man_pages
    screen tmux
    nnn
  ];

  home.sessionVariables = {
    NNN_OPENER = "${pkgs.nnn-src}/plugins/nuke";
  };

  custom.readline.enable = true;
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
}
