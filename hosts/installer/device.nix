{ config, lib, pkgs, ... }:

{
  device = {
    type = "embedded";
    isUefi = false;
    network.enable = false;

    zfs = {
      hostId = "8425e349";
      mount = false;
    };
  };
}
