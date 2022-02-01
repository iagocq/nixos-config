{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.adguard;
  nginx = config.srv.nginx;
in
{
  options.srv.adguard = {
    enable = mkEnableOption "Enable AdguardHome service";

    port = mkOption {
      type = types.port;
      default = 8333;
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
    };

    vhost = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    domain = mkOption {
      type = types.str;
      default = nginx.domain;
    };

    baseUri = mkOption {
      type = types.str;
      default = "/adguard/";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.adguardhome = {
        enable = true;
        port = cfg.port;
        host = cfg.address;
        extraArgs = [ "--no-etc-hosts" ];
      };

      networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 53 ];
    })

    (mkIf cfg.vhost {
      srv.nginx.vhosts.${cfg.domain} = mkIf cfg.vhost {
        locations = {
          ${cfg.baseUri} = {
            proxyPass = "http://${cfg.address}:${toString cfg.port}/";
            extraConfig = "proxy_redirect / ${cfg.baseUri};";
          };
        };
      };
    })
  ];
}
