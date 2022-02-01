{ config, lib, ... }:

with lib;

let
  base = ./.;
  ignore = [ "hm-modules" ];
  allFolders = builtins.attrNames (attrsets.filterAttrs (n: v: v == "directory") (builtins.readDir base));
  folders = builtins.filter (x: !(builtins.elem x ignore)) allFolders;
  modules = map (x: "${base}/${x}") folders;
  cfg = config.customUsers;
in
{
  imports = modules;

  options.customUsers.extra = mkOption {
    type = types.listOf types.str;
  };

  config = {
    users.users = mkMerge (map (x: { ${x} = { isNormalUser = true; initialHashedPassword = ""; }; }) cfg.extra);
  };
}
