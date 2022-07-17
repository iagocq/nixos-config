{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    zfs.hostId = "7afc33d1";

    network = {
      interfaces.dhcp = [ "enp3s0f0" "enp3s0f1" ];
      firewall = false;
    };

    audio = {
      quantum = 256;
    };
  };
}
