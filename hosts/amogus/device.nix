{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    uefi.removable = true;

    zfs.hostId = "93faae55";

    network = {
      interfaces.dhcp = [ "enp0s3" ];
      firewall = false;
    };
  };
}
