{ config, lib, pkgs, ... }:

with lib;
let
  path = ../../secrets;
  strip = file: builtins.replaceStrings [ "\n" ] [ "" ] (builtins.readFile file);
  secret = file: (path + "/${file}" );
  mkSecret = name: mkOption { type = types.str; default = strip (secret name); };
  mkSecretN = name: mkOption { type = types.anything; default = import (secret name); };
  loadSecrets =
    let
      contents = builtins.readDir path;
    in
    builtins.listToAttrs (map (file: {
      name = if strings.hasSuffix ".nix" file then builtins.substring 0 ((builtins.stringLength file) - 4) file else file;
      value = if strings.hasSuffix ".nix" file then mkSecretN file else mkSecret file;
    }) (builtins.attrNames contents))
  ;
in
{
  options.common.secrets = loadSecrets;
}
