{ config, pkgs, lib, users, ... }@args:

let
  s = config.common.secrets;
in
{
  users = {
    defaultUserShell = pkgs.zsh;

    users = lib.foldr (user: next: ( 
      let
        path = ./. + "/${user}.nix";
        attrs = {
          ${user} = import path args;
        };
        default = {
          ${user} = {
            isNormalUser = true;
          };
        };
      in if (builtins.pathExists path) then attrs else default
      ) // next) {} users;
  };

  environment.pathsToLink = [ "/share/zsh" ];
}
