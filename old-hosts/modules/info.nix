{ config, lib, pkgs, ... }@args:

with lib;
{
  options.common.info = mkOption {
    type = types.anything;
    default = import ../../config/info.nix args;
  };
}
