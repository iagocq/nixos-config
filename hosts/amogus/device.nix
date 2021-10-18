{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    uefi.removable = true;

    zfs = {
      mount = false;
      hostId = "93faae55";
    };
  };
}
