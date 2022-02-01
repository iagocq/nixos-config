{ config, lib, pkgs, ... }:

{
  device = {
    type = "embedded";

    boot.enable = false;
    network.enable = false;

    zfs = {
      mount = false;
      hostId = "a178ec85";
    };
  };
}
