{ config, lib, pkgs, ... }:

{
  device = {
    type = "embedded";

    uefi.enable = false;
    network.enable = false;

    zfs = {
      mount = false;
      hostId = "a178ec85";
    };
  };
}
