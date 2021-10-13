{ config, lib, pkgs, host ? "default", ... }:

let
  host-path = ./. + "/${host}";
  host-import = if builtins.pathExists host-path then [ host-path ] else [ ];
in
{
  imports = host-import;

  home.packages = with pkgs; [
    calc git git-crypt
    neofetch
    zip unzip p7zip atool
    man-pages posix_man_pages
    screen tmux
    nnn
  ];

  home.sessionVariables = {
    NNN_OPENER = "${pkgs.nnn.src}/plugins/nuke";
  };

  custom.readline.enable = true;
  custom.vim.enable = true;
  custom.shell.enable = true;
  custom.zsh.enable = true;
  custom.zsh.plugins = [
    {
      name = "fast-syntax-highlighting";
      src = pkgs.zsh-fast-syntax-highlighting.src;
    }
  ];

  home.username = "iago";
  home.homeDirectory = "/home/iago-nixos";
  home.stateVersion = "21.03";
}
