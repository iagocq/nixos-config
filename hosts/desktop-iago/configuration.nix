# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports = [
    ../pc.nix

    ./hardware-configuration.nix
  ];

  networking = {
    firewall.enable = false;
    wireless.enable = false;
    interfaces.enp8s0.useDHCP = true;
  };

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
  common.audio.default-playback = "alsa_output.pci-0000_09_00.1.hdmi-stereo";
  common.audio.default-capture = "alsa_input.usb-Generalplus_Usb_Audio_Device_13662631792-00.mono-fallback";

  common = {
    nginx = {
      enable = true;
      domain = "ng.localhost";
      ssl = { };
      sslExtraConfig = "";
      listen-on = [ { addr = "127.0.0.1"; port = 80; } ];
    };
    calibre.enable = true;
  };

  services.nginx.group = lib.mkForce "nginx";

  virtualisation.docker.enable = true;

  programs.gnupg.agent.enable = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "20.09";
}
