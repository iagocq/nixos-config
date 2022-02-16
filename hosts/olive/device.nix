{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    boot.loader = "grub";
    boot.removable = true;

    zfs.hostId = "5237d8c6";

    network = {
      interfaces.dhcp = [ "enp0s3" ];
      firewall = false;
    };
  };
}
