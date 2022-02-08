{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.dns;
  age = (import ./age.nix).age;
in
{
  options.spc.int.dns = with types; {
    enable = mkEnableOption "Use a specialized configuration for an internal DNS server";
  };

  config = mkIf cfg.enable {
    srv.adguard = {
      enable = true;
      address = "127.0.0.1";
      baseUri = "/adguard/";
      port = 8092;
    };

    srv.bind =
      let
        network = config.spc.int.network;
        
        secretPath = f: config.age.secrets.${f}.path;

        internal = [
          { domain = "iago.casa"; zone = secretPath "zone-iago-casa-internal"; }
        ];

        external = [
          { domain = "iago.casa"; zone = secretPath "zone-iago-casa-external"; }
        ];

        mkZones = zones: builtins.concatStringsSep "\n" (map (x: ''
          zone "${x.domain}" IN {
            type master;
            file "${x.zone}";
          };
        '') zones);
      in
      {
        enable = true;
        listenOn = [ network.server.mainAddress ];
        forwarders = [ network.dnsServer ];
        cacheNetworks = [ network.subnet ];
        extraConfig = ''
          acl internals {
            127.0.0.0/8;
            ${network.subnet};
          };

          view "internal" {
            match-clients { internals; };
            ${mkZones internal}
          };

          view "external" {
            match-clients { any; };
            ${mkZones external}
          };
        '';
        extraOptions = ''
          allow-recursion { cachenetworks; };
        '';
      };

    age.secrets = mkMerge [
      (age "zone-iago-casa-internal")
      (age "zone-iago-casa-external")
    ];
  };
}
