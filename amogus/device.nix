{ config, lib, pkgs, ... }:

{
  device = {
    type = "server";

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
      interfaces.dhcp = [ "enp0s3" ];
      firewall = false;
    };
  };
}
