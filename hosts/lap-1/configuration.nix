{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  i18n.defaultLocale = "pt_BR.UTF-8";

  zramSwap.enable = true;

  users.users.c = {
    initialHashedPassword = "";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    firefox libreoffice okular
  ];
}
