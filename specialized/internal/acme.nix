{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.spc.int.acme;
  age = (import ./age.nix).age;
in
{
  options.spc.int.acme = {
    enable = mkEnableOption "Use a specialized configuration for an internal ACME client";
  };

  config = mkIf cfg.enable {
    srv.acme = {
      enable = true;
      email = "18238046+iagocq@users.noreply.github.com";
      domain = config.spc.int.network.domain;
      credentials = config.age.secrets."acme-credentials".path;
      provider = "cloudflare";
    };

    age.secrets = age "acme-credentials";
  };
}
