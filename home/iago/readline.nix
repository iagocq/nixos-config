{ config, pkgs, lib, ... }:

{
  programs.readline = {
    enable = true;
    extraConfig = ''
      set colored-stats on
    '';
  };
}
