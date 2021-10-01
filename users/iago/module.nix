{ config, host ? "unknown", lib, pkgs, ... }:

{
  iago = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    home = "/home/iago-nixos";

    openssh.authorizedKeys.keys =
      let trusted = (import ../default.nix { inherit lib pkgs; }).iago.keys.trusted; in
      if trusted ? ${host} then trusted.${host} else [];
  };
}
