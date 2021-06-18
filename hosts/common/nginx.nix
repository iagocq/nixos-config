{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.nginx;
  s = config.common.secrets;
  mkVhost = vhost: {
    extraConfig = cfg.sslExtraConfig + (if (vhost ? extraConfig) then vhost.extraConfig else "");
    listen = cfg.listen-on;
  } // cfg.ssl // (removeAttrs vhost [ "extraConfig" ]);
in
{
  options.common.nginx = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
      default = s.network.domain;
    };

    ssl = mkOption {
      type = types.anything;
      default = {
        useACMEHost = cfg.domain;
        forceSSL = true;
      };
    };

    listen-on = mkOption {
      type = types.anything;
      default = [
        { addr = "0.0.0.0"; port = 443; ssl = true; }
        { addr = "0.0.0.0"; port = 80; }
        { addr = "[::]"; port = 443; ssl = true; }
        { addr = "[::]"; port = 80; }
      ];
    };

    resolver-addresses = mkOption {
      type = types.listOf types.str;
      default = [ s.network.dns-server ];
    };

    sslExtraConfig = mkOption {
      type = types.str;
      default = ''
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
        add_header X-Frame-Options DENY always;
        add_header X-Content-Type-Options nosniff always;
        add_header X-XSS-Protection "1; mode=block" always;
      '';
    };

    dhparams = mkOption {
      type = types.str;
      default = null;
    };

    bitwarden = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      domain = mkOption {
        type = types.str;
        default = "bw.${cfg.domain}";
      };

      address = mkOption {
        type = types.str;
        default = config.common.bitwarden_rs.config.rocketAddress;
      };

      port = mkOption {
        type = types.port;
        default = config.common.bitwarden_rs.config.rocketPort;
      };

      ws-address = mkOption {
        type = types.str;
        default = config.common.bitwarden_rs.config.websocketAddress;
      };

      ws-port = mkOption {
        type = types.port;
        default = config.common.bitwarden_rs.config.websocketPort;
      };
    };

    adguard = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      domain = mkOption {
        type = types.str;
        default = "ad.${cfg.domain}";
      };

      address = mkOption {
        type = types.str;
        default = config.common.adguard.address;
      };

      port = mkOption {
        type = types.port;
        default = config.common.adguard.port;
      };

      beta-port = mkOption {
        type = types.port;
        default = 0;
      };
    };
  };

  config = {
    services.nginx = mkIf cfg.enable {
      enable = true;

      group = "acme";

      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      resolver.addresses = cfg.resolver-addresses;
      proxyResolveWhileRunning = true;

      virtualHosts.${cfg.bitwarden.domain} = mkIf cfg.bitwarden.enable (mkVhost {
        locations = {
          "/" = {
            proxyPass = "http://${cfg.bitwarden.address}:${toString cfg.bitwarden.port}";
          };

          "/notifications/hub" = {
            proxyPass = "http://${cfg.bitwarden.ws-address}:${toString cfg.bitwarden.ws-port}";
            extraConfig = ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
            '';
          };

          "/notifications/negotiate" = {
            proxyPass = "http://${cfg.bitwarden.address}:${toString cfg.bitwarden.port}";
          };
        };
      });

      virtualHosts.${cfg.adguard.domain} = mkIf cfg.adguard.enable (mkVhost {
        locations = {
          "/" = {
            proxyPass = "http://${cfg.adguard.address}:${toString cfg.adguard.port}";
          };
          "/beta/" = mkIf (cfg.adguard.beta-port != 0) {
            proxyPass = "http://${cfg.adguard.address}:${toString cfg.adguard.beta-port}";
          };
        };
      });

      virtualHosts."${cfg.domain}" = mkVhost {
        listen = [ { addr = "0.0.0.0"; port = 2; ssl = true; } ];
        extraConfig = ''
          error_page 497 https://$host:2$request_uri;
        '';
        locations = {
          "/" = {
            return = "307 https://$host:2/mapa/";
          };
          "/mapa/" = {
            extraConfig = ''
              rewrite /mapa/(.*) /$1 break;
            '';
            proxyPass = "http://s1.${cfg.domain}:8100";
          };
        };
      };
    };
  };
}
