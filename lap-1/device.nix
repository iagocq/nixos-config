{ config, lib, pkgs, ... }:

{
  device = {
    type = "laptop";
    locale = "pt_BR.UTF-8";
    zfs.hostId = "c9693126";
    network.backend = "networkmanager";

    graphics = {
      backend = "x";

      autoLogin.user = "c";
      de = "xfce";
    };
  };
}
