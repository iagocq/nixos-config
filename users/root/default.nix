{ lib }:
{
  keys = lib.mkKeys (import ./keys.nix);
}
