{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.gtk;
in
{
  options.custom.gtk = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    gtk = mkIf cfg.enable {
      enable = true;
      font.package = pkgs.noto-fonts;
      font.name = "Noto Sans 10";
      gtk3.extraCss = builtins.readFile ./gtk/gtk.css;
      gtk3.extraConfig = {
        gtk-button-images = 1;
        gtk-enable-animations = 1;
        gtk-menu-images = 1;
      };
    };
  };
}
