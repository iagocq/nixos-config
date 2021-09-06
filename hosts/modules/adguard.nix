{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.adguard;
in
{
  options.common.adguard = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

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
      default = true;
    };

    domain = mkOption {
      type = types.str;
      default = "ad.${config.common.nginx.domain}";
    };

    base-uri = mkOption {
      type = types.str;
      default = "/";
    };

    open-firewall = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      port = cfg.port;
      host = cfg.address;
      extraArgs = [ "--no-etc-hosts" ];
    };

    common.nginx.vhosts.${cfg.domain} = mkIf cfg.vhost {
      locations = {
        ${cfg.base-uri} = {
          proxyPass = "http://${cfg.address}:${toString cfg.port}";
        };
      };
    };

    networking.firewall.allowedUDPPorts = [ 53 ];
  };
}
