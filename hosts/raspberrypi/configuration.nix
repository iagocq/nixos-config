{ config, pkgs, lib, ... }:

let
  s = config.common.secrets;
in
{
  imports = [
    ../common/configuration.nix

    ./hardware-configuration.nix
  ];

  networking.hostName = "raspberrypi";
  networking.firewall.enable = false;
  networking.wireless.enable = false;
  networking.interfaces.eth0.ipv4 = {
    addresses = s.network.raspberrypi.addresses;
    routes = [ s.network.default-route ];
  };
  networking.nameservers = [ s.network.dns-server ];
  networking.extraHosts = s.network.raspberrypi.extraHosts;
  networking.domain = s.network.intranet-domain;

  common.bitwarden_rs.enable = true;
  common.adguard.enable = true;
  common.acme.enable = true;
  common.dnsmasq.enable = true;
  common.nginx.enable = true;
  common.nginx.bitwarden.enable = true;
  common.nginx.adguard.enable = true;
  common.nginx.adguard.betaPort = config.common.nginx.adguard.port + 1;
  common.bind.enable = true;

  system.stateVersion = "20.09";
}
