{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.firefox;
in
{
  options.custom.firefox = {
    enable = mkEnableOption "";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.iago = {
        isDefault = true;
        userChrome = builtins.readFile ./firefox/userChrome.css;
      };
    };
  };
}
