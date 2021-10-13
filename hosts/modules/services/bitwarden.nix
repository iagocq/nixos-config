{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.bitwarden;
  nginx = config.srv.nginx;
in
{
  options.srv.bitwarden = {
    enable = mkEnableOption "Enable bitwarden service";

    config = mkOption {
      type = types.attrsOf types.anything;
    };

    domain = mkOption {
      type = types.str;
      default = nginx.domain;
    };

    vhost = mkOption {
      type = types.bool;
      default = cfg.enable;
    };

    baseUri = mkOption {
      type = types.str;
      default = "/bitwarden/";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      services.vaultwarden = {
        enable = true;
        config = cfg.config;
      };
    })
    
    (mkIf cfg.vhost {
      srv.nginx.vhosts.${cfg.domain} = {
        locations = {
          "${cfg.baseUri}" = {
            proxyPass = "http://${cfg.config.rocketAddress}:${toString cfg.config.rocketPort}";
          };

          "${cfg.baseUri}notifications/hub" = mkIf cfg.config.websocketEnabled {
            proxyPass = "http://${cfg.config.websocketAddress}:${toString cfg.config.websocketPort}";
            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };
        };
      };
    })
  ];
}
