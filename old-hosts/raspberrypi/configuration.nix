{ config, pkgs, lib, ... }:

let
  info = config.common.info;
  lan = info.network.lan;
in
{
  imports = [
    ../configuration.nix

    ./hardware-configuration.nix
  ];
  
  nix.trustedUsers = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;
  
  networking = {
    firewall.enable = true;
    wireless.enable = false;
    interfaces.eth0.ipv4 = {
      addresses = lan.server.addresses;
      routes = [ lan.default-route ];
    };
    nameservers = [ lan.dns-server ];
    extraHosts = lan.server.extra-hosts;
    domain = lan.lan-domain;
    resolvconf.useLocalResolver = false;
  };

  common = {
    bitwarden_rs = {
      enable = true;
      base-uri = "/bitwarden/";
    };

    adguard = {
      enable = true;
      base-uri = "/adguard/";
      port = 8092;
    };

    nginx = {
      enable = true;
      dynamic-resolving = false;
      extra-config = [ "client_max_body_size 200m;" ];
    };

    bind = {
      enable = true;

      extra-config = info.bind.config;
      extra-options = info.bind.options;
    }; 

    calibre = {
      enable = true;
      port = 8094;
    };

    acme.enable = true;
    dnsmasq.enable = true;
    lightspeed.enable = true;
    lightspeed.webrtc.ws-port = 8093;
  };

  system.stateVersion = "20.09";
}
