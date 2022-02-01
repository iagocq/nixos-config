{ config, host, lib, pkgs, usersLib, ... }:

with lib;
let
  cfg = config.customUsers.iago;
in
{
  options.customUsers.iago = {
    enable = mkEnableOption "";

    homeManager = mkOption {
      type = types.bool;
      default = config.device.homeManagerEnabled;
    };

    keys = mkOption {
      type = types.listOf types.str;
      default = (import ./keys.nix).trusted.${host} or [];
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (!config.device.isHomeManager) {
      users.users.iago = {
        shell = pkgs.zsh;
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        home = "/home/iago-nixos";
        hashedPassword = "$6$helloWORLD$tbPL0CQSL38dDGLwCtRFRZ.BuHRtyJFjJDXNaDufP91PIGNnI5CGPEjaZJ4PyYp6noX5TF40Ijj1zxG59HxiC/";

        openssh.authorizedKeys.keys = cfg.keys;
      };
    })

    (mkIf cfg.homeManager {
      home-manager.users.iago = import ./home.nix;
    })
  ]);
}
