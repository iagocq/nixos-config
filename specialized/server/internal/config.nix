{ config, lib, ... }:

with lib;
let
  secrets = config.age.secrets;
in
{
  spc.int.cfg = rec {
    email = "18238046+iagocq@users.noreply.github.com";

    bind =
      let
        zones.internal = [
          { domain = "iago.casa"; zone = "/run/secrets/zone-iago-casa-internal"; }
        ];

        zones.external = [
          { domain = "iago.casa"; zone = "/run/secrets/zone-iago-casa-external"; }
        ];

        mkZones = zones: builtins.concatStringsSep "\n" (map (x: ''
          zone "${x.domain}" IN {
            type master;
            file "${x.zone}";
          };
        '') zones);

        internal = mkZones zones.internal;
        external = mkZones zones.external;
      in
      {
        secrets = [
          "zone-iago-casa-internal"
          "zone-iago-casa-external"
        ];

        extraConfig = ''
          acl internals {
            127.0.0.0/8;
            ${network.subnet};
          };

          view "internal" {
            match-clients { internals; };
            ${internal}
          };

          view "external" {
            match-clients { any; };
            ${external}
          };
        '';

        extraOptions = ''
          allow-recursion { cachenetworks; };
        '';

        listenOn = [ network.server.mainAddress ];

        forwarders = [ network.dnsServer ];
        cacheNetworks = [ network.subnet ];
      };

    adguard = {
      address = "127.0.0.1";
      baseUri = "/adguard/";
      port = 8092;
    };

    bitwarden = rec {
      inherit (nginx) domain;
      baseUri = "/bitwarden/";
      config = {
        websocketEnabled = true;
        websocketAddress = "127.0.0.1";
        websocketPort = 8091;
        signupsAllowed = false;
        domain = "https://${domain}${baseUri}";
        rocketAddress = "127.0.0.1";
        rocketPort = 8090;
      };
    };

    calibre = {
      address = "127.0.0.1";
      baseUri = "/calibre";
      port = 8094;
    };

    acme = {
      secrets = [
        "acme-credentials"
      ];

      inherit email;
      inherit (network) domain;

      credentials = "/run/secrets/acme-credentials";
      provider = "cloudflare";
    };

    lightspeed = {
      webrtc.wsPort = 8093;
    };

    network = rec {
      domain = "iago.casa";
      lanSubdomain = "intra";
      lanDomain = "${lanSubdomain}.${domain}";
      net = "10.36.21.";
      netmask = "255.255.255.0";
      subnet = "${net}0/24";
      broadcast = "${net}255";
      dnsServer = "${net}11";
      gateway = "${net}1";

      defaultRoute = {
        address = "0.0.0.0";
        prefixLength = 0;
        via = gateway;
      };

      server = {
        host = "raspberrypi";
        mainAddress = "${net}10";
        addresses = [
          { address = "${net}10"; prefixLength = 24; }
          { address = "${net}11"; prefixLength = 24; }
        ];
        extraHosts = "";
      };
    };

    dnsmasq = with network;
      let
        start = "${net}30";
        end = "${net}99";
      in
      {
        domain = lanDomain;
        dhcpRange = "${start},${end},${netmask},${broadcast}";
        dhcpSubnet = subnet;
        router = gateway;
        dnsServer = dnsServer;
        extraConfig = ''
          host-record=${server.host}.${lanDomain},${server.host},${server.mainAddress}
        '';
      };

    nginx = {
      inherit (network) domain;
      dynamicResolving = false;
    };
  };
}
