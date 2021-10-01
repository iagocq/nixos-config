{ config, lib, pkgs, users ? [], users-path ? ../../users, ... }@args:

with lib;
let
  cfg = config.common.users;

  all-users = import users-path { inherit lib pkgs; };
  ulib = all-users.lib;
in
{
  options.common.users = {
    enable = mkOption {
      type = types.bool;
      default = true;
    };

    imported = mkOption {
      type = types.anything;
      default = ulib.loadUsers all-users users;
    };

    modules = mkOption {
      type = types.anything;
      default = ulib.listOf "module" cfg.imported;
    };

    default-shell = mkOption {
      type = types.package;
      default = pkgs.zsh;
    };
  };

  config = mkIf cfg.enable {
    users.users = lib.lists.foldr (u: t: lib.attrsets.recursiveUpdate (u args) t) {} cfg.modules;
    users.defaultUserShell = cfg.default-shell;
  };
}
