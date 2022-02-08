{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.nginx;
in
{
  options.spc.int.nginx = {
    enable = mkEnableOption "use a specialized configuration for an internal server";
  };

  config = mkIf cfg.enable {
    srv.nginx = {
      domain = config.spc.int.network.domain;
      dynamicResolving = false;
    };
  };
}
