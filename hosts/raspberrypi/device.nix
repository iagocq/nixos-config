{ config, lib, pkgs, ... }:

{
  device = {
    type = "embedded";

    uefi.bootloader = "extlinux";

    zfs = {
      hostId = "40cf60c9";
      mount = false;
    };

    network = {
      interfaces.static.eth0.ipv4 = let network = config.spc.int.cfg.network or {}; in {
        addresses = network.server.addresses or [];
        routes = [ (network.defaultRoute or {}) ];
      };
    };
  };
}
