{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.acme;
in
{
  options.srv.acme = {
    enable = mkEnableOption "Enable ACME service";

    email = mkOption {
      type = types.str;
    };

    domain = mkOption {
      type = types.str;
    };

    credentials = mkOption {
      type = types.nullOr types.str;
    };

    provider = mkOption {
      type = types.str;
    };

    extraDomains = mkOption {
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
        extraDomainNames = cfg.extraDomains;
      };
    };
  };
}
