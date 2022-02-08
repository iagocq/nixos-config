{ config, lib, pkgs, ... }:

{
  device = {
    type = "embedded";

    boot.loader = "raspberrypi";

    zfs = {
      hostId = "40cf60c9";
      mount = false;
    };

    network = {
      wireless = true;

      interfaces.static = let network = config.spc.int.network; in rec {
        eth0.ipv4 = {
          addresses = network.server.addresses or [];
        };

        wlan0.ipv4 = eth0.ipv4 // {
          routes = [ (network.defaultRoute or {}) ];
        };
      };
    };
  };
}
