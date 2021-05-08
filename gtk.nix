{ config, pkgs, lib, ... }:

{
  gtk.enable = true;
  gtk.font.package = pkgs.noto-fonts;
  gtk.font.name = "Noto Sans 10";
  gtk.gtk3.extraCss = builtins.readFile ./gtk/gtk.css;
  gtk.gtk3.extraConfig = {
    gtk-button-images = 1;
    gtk-enable-animations = 1;
    gtk-menu-images = 1;
  };
}
