{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.srv.sslh;
in
{
  options.srv.sslh = {
    enable = mkOption {
      default = false;
    };
  };
}
