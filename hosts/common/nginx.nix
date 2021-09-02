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

    dynamic-resolving = mkOption {
      type = types.bool;
      default = true;
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

    vhosts = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };

    group = mkOption {
      type = types.str;
      default = "acme";
    };
  };

  config = {
    services.nginx = mkIf cfg.enable {
      enable = true;

      group = cfg.group;

      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedTlsSettings = true;

      resolver.addresses = mkIf cfg.dynamic-resolving cfg.resolver-addresses;
      proxyResolveWhileRunning = mkDefault cfg.dynamic-resolving;

      virtualHosts = {
        ${cfg.domain} = mkVhost {
          extraConfig = ''
            error_page 497 https://$host$request_uri;
          '';
          locations = {
            "/" = {
              return = "307 https://$host/mapa/";
            };
            "/mapa/" = {
              extraConfig = ''
                rewrite /mapa/(.*) /$1 break;
              '';
              proxyPass = "http://s1.${cfg.domain}:8100";
            };
          };
        };
      } // builtins.mapAttrs (name: value: mkVhost value) cfg.vhosts;
    };
  };
}
