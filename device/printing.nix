{ config, lib, pkgs, isHomeManager ? false, ... }:

with lib;
let
  cfg = config.device.printing;
in
{
  options.device.printing = {
    enable = mkOption {
      type = types.bool;
      default = config.device.isPc;
    };
  };

  config = if !isHomeManager then mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
        userServices = true;
      };
    };
  } else {};
}
