{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.terminal;
in
{
  options.custom.terminal = {
    cmd = mkOption {
      type = types.str;
      default = "${pkgs.xterm}/bin/xterm";
    };
  };
}
