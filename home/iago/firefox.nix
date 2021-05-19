{ config, pkgs, lib, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.iago = {
      isDefault = true;
      userChrome = builtins.readFile ./firefox/userChrome.css;
    };
  };
}
