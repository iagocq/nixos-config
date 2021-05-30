{ config, lib, pkgs, ... }@args:

with lib;
let
  path = ../../secrets;
  secret = file: (path + "/${file}" );

  mkSecret = name:
  let
    raw-module = import (secret name);
    module = if builtins.typeOf raw-module == "lambda" then raw-module args else raw-module;
  in
    mkOption {
      type = types.anything;
      default = module;
    };

  loadSecrets =
  let
    contents = builtins.readDir path;
    nix-only = builtins.filter (x: strings.hasSuffix ".nix" x) (builtins.attrNames contents);
  in
    builtins.listToAttrs (map (file: {
      name = builtins.substring 0 ((builtins.stringLength file) - 4) file;
      value = mkSecret file;
    }) nix-only);

in
{
  options.common.secrets = loadSecrets;
}
