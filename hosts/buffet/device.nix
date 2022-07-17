{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    zfs = {
      hostId = "7afc33d1";
      eyd.enable = true;
    };

    network = {
      firewall = false;
    };

    audio = {
      quantum = 256;
    };
  };
}
