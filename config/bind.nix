{ config, ... }:
let
  secrets = config.age.secrets;
  network = import ./network.nix;
  lan = network.lan;
in
rec {
  zones.internal = [
    { domain = "iago.casa"; zone = secrets.zone-iago-casa-internal.path; }
  ];

  zones.external = [
    { domain = "iago.casa"; zone = secrets.zone-iago-casa-external.path; }
  ];

  config =
    let
      mkZones = zones: builtins.concatStringsSep "\n" (map (x: ''
        zone "${x.domain}" IN {
          type master;
          file "${x.zone}";
        };
      '') zones);
      internal-zones = mkZones zones.internal;
      external-zones = mkZones zones.external;
    in ''
      acl internals {
        127.0.0.0/8;
        ${lan.subnet};
      };

      view "internal" {
        match-clients { internals; };
        ${internal-zones}
      };

      view "external" {
        match-clients { any; };
        ${external-zones}
      };
    '';

  options = ''
    allow-recursion { cachenetworks; };
  '';
}
