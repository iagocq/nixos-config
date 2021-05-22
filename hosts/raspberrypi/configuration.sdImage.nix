nixpkgs:
{ config, lib, pkgs, ... }:

{
  imports = [
    ( import "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix" )
    ./configuration.nix
  ];

  sdImage.compressImage = false;
}
