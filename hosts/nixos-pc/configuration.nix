# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/configuration.nix
    ../common/pc.nix

    ./hardware-configuration.nix
  ];

  services.xserver = {
    enable = true;
    layout = "br";
    displayManager.sddm.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "iago";
    displayManager.sddm.autoLogin.relogin = true;
    displayManager.defaultSession = "xfce+i3";
    desktopManager = {
      xfce.enable = true;
      xfce.noDesktop = true;
      xfce.enableXfwm = false;
    };
    windowManager.i3.enable = true;
    windowManager.i3.package = pkgs.i3-gaps;
  };

  users.users.iago = {
    extraGroups = [ "jackaudio" "audio" "docker" ];
  };

  common.audio.quantum = 256;

  virtualisation.docker.enable = true;

  programs.gnupg.agent.enable = true;

  networking.firewall.enable = false;

  nixpkgs.config.allowUnfree = true;
  
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "20.09";

}
