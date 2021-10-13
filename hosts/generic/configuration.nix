{ config, lib, pkgs, ... }:

{
  imports = [
    ./device.nix
  ];

  services.getty.autologinUser = lib.mkForce "iago";

  nix.trustedUsers = [ "root" "@wheel" ];
}
