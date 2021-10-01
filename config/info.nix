{ config, lib, pkgs, ... }@args:
let
  secrets = config.age.secrets;
in
{
  email = "18238046+iagocq@users.noreply.github.com";

  acme = {
    credentials = secrets.acme-credentials.path;
    provider = "dynu";
  };

  bind = import ./bind.nix args;

  network = import ./network.nix;
}
