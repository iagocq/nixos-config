{ lib ? null, pkgs ? null }:
let
  ulib = import ./lib.nix { inherit lib pkgs; };
  user = u: import u { lib = ulib; };
in
{
  lib = ulib;
  iago = user ./iago;
  root = user ./root;
  default = user ./default;
}
