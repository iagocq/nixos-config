{ config, lib, pkgs, ... }:

{
  imports = [
    ./modules.nix

    ./users.nix
    ./ssh.nix
  ];

  time.timeZone = "America/Sao_Paulo";

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim htop file killall nethogs dnsutils coreutils lsof
  ];

  # https://github.com/NixOS/nixpkgs/issues/124215
  documentation.info.enable = false;

  # https://github.com/NixOS/nixpkgs/pull/85073
  systemd.services.mount-pstore.enable = false;
}
