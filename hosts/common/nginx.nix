{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.nginx;
  mkVhost = vhost: 
    { extraConfig = cfg.sslExtraConfig
        + (if builtins.hasAttr "extraConfig" vhost then vhost.extraConfig else ""); }
    // cfg.ssl
    // (lib.attrsets.filterAttrs (n: v: n != "extraConfig") vhost);
in
{
  options.common.nginx = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
      default = "${config.common.secrets.domain}";
    };

    ssl = mkOption {
      type = types.anything;
      default = {
        useACMEHost = "${cfg.domain}";
        forceSSL = true;
      };
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

    adhole = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };

      domain = mkOption {
        type = types.str;
        default = "ad.${cfg.domain}";
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
    };
  };
}
