{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./device.nix
  ];

  boot = {
    plymouth.enable = true;
    loader.timeout = 1;
  };

  nix.trustedUsers = [ "root" "@wheel" ];

  users.users.c = {
    initialHashedPassword = "";
    isNormalUser = true;
  };

  environment.systemPackages = with pkgs; [
    firefox libreoffice okular
  ];

  zramSwap.enable = true;

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
