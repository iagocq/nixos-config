{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/configuration.nix

    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos-rpi";
  networking.firewall.enable = false;
  networking.wireless.enable = false;
  networking.interfaces.eth0.ipv4 = {
    addresses = [
      {
        address = "192.168.0.10";
        prefixLength = 24;
      }
      {
        address = "192.168.0.11";
        prefixLength = 24;
      }
    ];
    routes = [
      {
        address = "0.0.0.0";
        prefixLength = 0;
        via = "192.168.0.1";
      }
    ];
  };
  networking.nameservers = [ "1.1.1.1" ];

  system.stateVersion = "20.09";
}