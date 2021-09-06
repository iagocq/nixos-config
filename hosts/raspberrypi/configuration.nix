{ config, pkgs, lib, ... }:

let
  s = config.common.secrets;
in
{
  imports = [
    ../configuration.nix

    ./hardware-configuration.nix
  ];
  
  networking = {
    firewall.enable = true;
    wireless.enable = false;
    interfaces.eth0.ipv4 = {
      addresses = s.network.raspberrypi.addresses;
      routes = [ s.network.default-route ];
    };
    nameservers = [ s.network.dns-server ];
    extraHosts = s.network.raspberrypi.extra-hosts;
    domain = s.network.intranet-domain;
    resolvconf.useLocalResolver = false;
  };

  common = {
    bitwarden_rs = {
      enable = true;
      base-uri = "/bitwarden/";
      domain = config.common.nginx.domain;
    };

    adguard = {
      enable = true;
      base-uri = "/adguard/";
      domain = config.common.nginx.domain;
    };

    acme.enable = true;
    dnsmasq.enable = true;
    nginx.enable = true;
    bind.enable = true;
    lightspeed.enable = true;
    lightspeed.webrtc.ws-port = 8090;
  };

  system.stateVersion = "20.09";
}
