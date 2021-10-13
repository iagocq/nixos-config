{ config, lib, pkgs, ... }:

{
  device = {
    type = "laptop";
    zfs.hostId = "c9693126";

    network.backend = "networkmanager";

    graphics = {
      backend = "x";

      autoLogin.user = "c";
      de = "xfce";
    };
  };
}
