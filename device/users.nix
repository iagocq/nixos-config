{ config, lib, pkgs, users ? [], ... }@args:

with lib;
let
  cfg = config.device.users;

  allUsers = import ../users { inherit lib pkgs; };
  ulib = allUsers.lib;
in
{
  options.device.users = {
    enable = mkOption {
      type = types.bool;
      default = !config.device.isHomeManager;
    };

    imported = mkOption {
      type = types.anything;
      default = ulib.loadUsers allUsers users;
    };

    modules = mkOption {
      type = types.listOf types.anything;
      default = map (x: x) (ulib.listOf "module" cfg.imported);
    };
  };

  config = mkIf cfg.enable (mkMerge (map (x: x args) (ulib.listOf "module" (ulib.loadUsers allUsers users))));
}
