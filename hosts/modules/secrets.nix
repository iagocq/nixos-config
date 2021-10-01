{ config, lib, pkgs, ... }@args:

with lib;
let
  cfg = config.common.secrets;

  age-secrets = (import cfg.secrets-file).age;
in
{
  options.common.secrets = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    secrets-file = mkOption {
      type = types.path;
      default = ../../config/age.nix;
    };
  };

  config = mkIf cfg.enable {
    age.secrets = age-secrets;
  };
}
