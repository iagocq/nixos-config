# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./audio.nix
      ./hardware-configuration-pc.nix
    ];

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  networking.useDHCP = false;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
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

  # Enable OpenGL for 32-bit programs.
  hardware.opengl.driSupport32Bit = true;

  users.users.iago = {
    isNormalUser = true;
    extraGroups = [ "wheel" "jackaudio" "audio" "docker" ];
    home = "/home/iago-nixos";
    shell = pkgs.zsh;
  };

  environment.systemPackages = with pkgs; [
    vim htop file killall nethogs dnsutils coreutils lsof
  ];

  environment.pathsToLink = [ "/share/zsh" ];
  
  # Services
  services.openssh.enable = true;
  services.openssh.useDns = true;

  virtualisation.docker.enable = true;

  services.printing.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };
  
  programs.gnupg.agent.enable = true;

  networking.firewall.enable = false;

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
