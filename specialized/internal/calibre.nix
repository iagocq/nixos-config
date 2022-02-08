{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.calibre;
in
{
  options.spc.int.calibre = {
    enable = mkEnableOption "Use a specialized configuration for an internal calibre server";
  };

  config = mkIf cfg.enable {
    srv.calibre = {
      enable = true;
      address = "127.0.0.1";
      baseUri = "/calibre";
      port = 8094;
    };
  };
}
