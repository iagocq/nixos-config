{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.acme;
in
{
  options.common.acme = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    domain = mkOption {
      type = types.str;
      default = config.common.secrets.domain;
    };
  };

  config = {
    security.acme = mkIf cfg.enable {
      acceptTerms = true;
      email = mkDefault config.common.secrets.email;
      certs."${cfg.domain}" = {
        credentialsFile = mkDefault config.common.secrets.acme-creds-file;
        dnsProvider = mkDefault config.common.secrets.acme-provider;
        extraDomainNames = [ "*.${cfg.domain}" ];
      };
    };
  };
}
