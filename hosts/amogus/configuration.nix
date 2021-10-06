{ config, lib, pkgs, ... }:

{
  imports = [
    ../configuration.nix

    ./hardware-configuration.nix
  ];

  networking.interfaces.enp0s3.useDHCP = true;

  users.users.iago.initialHashedPassword = "";
}
