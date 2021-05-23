{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.acme;
  s = config.common.secrets;
in
{
  options.common.acme = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    security.acme = mkIf cfg.enable {
      acceptTerms = true;
      email = s.acme.email;
      certs."${s.acme.domain}" = {
        credentialsFile = pkgs.writeText "acme-env" s.acme.env;
        dnsProvider = mkDefault s.acme.provider;
        extraDomainNames = [ "*.${s.acme.domain}" ];
      };
    };
  };
}
