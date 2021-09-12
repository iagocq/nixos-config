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
      config.rocketPort = 8090;
      config.websocketPort = 8091;
    };

    adguard = {
      enable = true;
      base-uri = "/adguard/";
      port = 8092;
    };

    nginx = {
      enable = true;
      dynamic-resolving = false;
    };

    acme.enable = true;
    dnsmasq.enable = true;
    bind.enable = true;
    lightspeed.enable = true;
    lightspeed.webrtc.ws-port = 8093;
    calibre.enable = true;
    calibre.port = 8094;
  };

  system.stateVersion = "20.09";
}
