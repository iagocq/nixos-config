{ config, lib, pkgs, type ? "unknown", ... }:

with lib;
{
  options.common.device = {
    type = mkOption {
      type = types.enum [ "unknown" "desktop" "notebook" "embedded" "server" ];
      default = type;
    };

    net-devices = mkOption {
      type = types.listOf types.str;
      default = [ "eth0" ];
    };
  };
}
