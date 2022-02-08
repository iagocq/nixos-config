{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.int.ap;
  int-cfg = config.spc.int.cfg;
in
{
  options.spc.int.ap  {
    enable = mkEnableOption "Use a specialized configuration for a WiFi Access Point";
  };

  config = mkIf cfg.enable {
  };
}
