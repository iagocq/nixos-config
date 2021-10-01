{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.acme;
  info = config.common.info;
  network = info.network;
in
{
  options.common.acme = {
    enable = mkEnableOption "Enable ACME service";

    email = mkOption {
      type = types.str;
      default = info.email;
    };

    domain = mkOption {
      type = types.str;
      default = network.domain;
    };

    credentials = mkOption {
      type = types.str;
      default = info.acme.credentials;
    };

    provider = mkOption {
      type = types.str;
      default = info.acme.provider;
    };

    extra-domains = mkOption {
      type = types.listOf types.str;
      default = [ "*.${cfg.domain}" ];
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;
      email = cfg.email;
      certs.${cfg.domain} = {
        credentialsFile = mkIf (cfg.credentials != null) cfg.credentials;
        dnsProvider = cfg.provider;
        extraDomainNames = cfg.extra-domains;
      };
    };
  };
}
