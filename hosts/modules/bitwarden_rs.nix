{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.bitwarden_rs;
in
{
  options.common.bitwarden_rs = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    config = mkOption {
      type = types.anything;
      default = {
        websocketEnabled = true;
        websocketAddress = "127.0.0.1";
        websocketPort = 3012;
        signupsAllowed = false;
        domain = "https://${cfg.domain}${cfg.base-uri}";
        rocketAddress = "127.0.0.1";
        rocketPort = 8222;
      };
    };

    domain = mkOption {
      type = types.str;
      default = ${config.common.nginx.domain};
    };

    vhost = mkOption {
      type = types.bool;
      default = true;
    };

    base-uri = mkOption {
      type = types.str;
      default = "/";
    };
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = cfg.config;
    };

    common.nginx.vhosts.${cfg.domain} = mkIf cfg.vhost {
      locations = {
        "${cfg.base-uri}" = {
          proxyPass = "http://${cfg.config.rocketAddress}:${toString cfg.config.rocketPort}";
        };

        "${cfg.base-uri}notifications/hub" = mkIf cfg.config.websocketEnabled {
          proxyPass = "http://${cfg.config.websocketAddress}:${toString cfg.config.websocketPort}";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
          '';
        };
      };
    };
  };
}
