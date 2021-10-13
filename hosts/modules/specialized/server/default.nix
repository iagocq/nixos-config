{ config, lib, pkgs, ... }:

{
  imports = [
    ./internal
    ./external
  ];
}
