{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.common.minecraft-map;
  s = config.common.secrets;
in
{
  options.common.minecraft-map = {
    enable = mkEnableOption "";

    address = mkOption {
      type = types.str;
      default = ;
    };

    port = mkOption {
    };

    url = mkOption {
      type = types.str;
      default = "http://${cfg.address}:${cfg.port}";
    };
  };
