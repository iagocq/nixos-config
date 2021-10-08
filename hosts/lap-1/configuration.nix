{ config, lib, pkgs, ... }:

{
  imports = [
    ../pc.nix

    ./hardware-configuration.nix
  ];

  networking.firewall.enable = true;
  networking.networkmanager.enable = true;
  networking.hostId = "1f831300";

  users.users.c = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
  };

  services.xserver = {
    enable = true;
    layout = "br";
    displayManager = {
      autoLogin.enable = true;
      autoLogin.user = "c";
      sddm.enable = true;
      sddm.autoLogin.relogin = true;
    };
    desktopManager = {
      xfce.enable = true;
    };
  };

  i18n.defaultLocale = "pt_BR.UTF-8";

  system.stateVersion = "21.05";
}
