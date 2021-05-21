{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.common.secrets;
  strip = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
in
{
  options.common.secrets = {
    domain = mkOption {
      type = types.str;
      default = strip ../../secrets/domain;
    };

    email = mkOption {
      type = types.str;
      default = strip ../../secrets/email;
    };

    acme-creds-file = mkOption {
      type = types.str;
      default = strip ../../secrets/acme-creds-file;
    };

    acme-provider = mkOption {
      type = types.str;
      default = strip ../../secrets/acme-provider;
    };
  };
}
