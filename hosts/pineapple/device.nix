{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

    boot.loader = "grub";
    boot.removable = true;

    zfs = {
      hostId = "93faae55";
      eyd.persist = {
        directories = [
          "/var/lib/private/gitlab-runner"
        ];
      };
    };

    network = {
      interfaces.static.enp0s3.ipv4 = {
        addresses = [
          { address = "10.0.0.195"; prefixLength = 24; }
        ];
        routes = [
          {
            address = "0.0.0.0";
            prefixLength = 0;
            via = "10.0.0.1";
          }
        ];
      };
      firewall = false;
    };
  };
}
