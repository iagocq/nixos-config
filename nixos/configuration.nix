# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let baseConfig = { allowUnfree = true; };
    pipewire-utils = import ./pipewire-utils.nix { lib = lib; };
    pw-pa-virtual-sinks = pipewire-utils.virtual-sinks;
    pw-pa-virtual-sources = pipewire-utils.virtual-sources;
    quantum = 512;
    quantumstr = builtins.toString quantum;
    #unstable = import <nixos-unstable> { config = baseConfig; };
in
{
  #nix.binaryCaches = [ "https://aseipp-nix-cache.freetls.fastly.net" ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #<nixos-unstable/nixos/modules/services/desktops/pipewire/pipewire.nix>
    ];
  #disabledModules = [ "services/desktops/pipewire.nix" ];

  nixpkgs.config = baseConfig // { 
  #  packageOverrides = pkgs: { pipewire = unstable.pipewire; };
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "nodev";
    efiSupport = true;
    enableCryptodisk = true;
  };
  boot.initrd = {
    luks.devices."root" = {
      device = "/dev/disk/by-uuid/0a07d8fc-b24f-43fc-b428-87d336eb8145";
      preLVM = true;
      keyFile = "/cryptlvm-key.bin";
      allowDiscards = true;
    };
    secrets = {
      "cryptlvm-key.bin" = "/boot/cryptlvm-key.bin";
    };
  };

  networking.hostName = "nixos-pc"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp8s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  services.xserver = {
    enable = true;
    layout = "br";
    videoDrivers = [ "nvidia" ];
    dpi = 96;
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
    screenSection = ''
      Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
      Option "TripleBuffer" "on"
      Option "AllowIndirectGLXProtocol" "off"
    '';
  };

  # Enable OpenGL for 32-bit programs.
  hardware.opengl.driSupport32Bit = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.package = unstable.pulseaudioFull;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    config.pipewire = {
      "context.properties" = {
        "default.clock.quantum" = quantum;
        "default.clock.min-quantum" = quantum;
        "default.clock.max-quantum" = quantum;
        "log.level" = 2;
        "link.max-buffers" = 16;
      };
      "context.objects" = [
        {
          factory = "spa-node-factory";
          args = {
            "factory.name" = "support.node.driver";
            "node.name" = "Dummy-Driver";
            "priority.driver" = 8000;
          };
        }
      ] ++ (pw-pa-virtual-sinks   [ "Voice" "Desktop" "Extra" ])
        ++ (pw-pa-virtual-sources [ "Voice" "Mixed"   "Extra" ]);
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        {
          name = "libpipewire-module-portal";
          flags = [ "ifexists" "nofail" ];
        }
        {
          name = "libpipewire-module-access";
          args = {};
        }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
      ];
    };
    config.pipewire-pulse = {
      "context.properties" = {
        "log.level" = 2;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rtkit";
          args = {
            "nice.level" = -15;
            "rt.prio" = 88;
            "rt.time.soft" = 200000;
            "rt.time.hard" = 200000;
          };
          flags = [ "ifexists" "nofail" ];
        }
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            "pulse.min.req" = "${quantumstr}/48000";
            "pulse.default.req" = "${quantumstr}/48000";
            "pulse.max.req" = "${quantumstr}/48000";
            "pulse.min.quantum" = "${quantumstr}/48000";
            "pulse.max.quantum" = "${quantumstr}/48000";
            "server.address" = [ "unix:native" ];
          };
        }
      ];
      "stream.properties" = {
        "node.latency" = "${quantumstr}/48000";
        "resample.quality" = 1;
      };
    };
  };

  #environment.etc."alsa/conf.d/50-jack.conf".source = "${pkgs.alsaPlugins}/etc/alsa/conf.d/50-jack.conf";
  security.pam.loginLimits = [
    { domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
    { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  security.rtkit.enable = true;

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.iago = {
    isNormalUser = true;
    extraGroups = [ "wheel" "jackaudio" "audio" ];
    home = "/home/iago-nixos";
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim htop file killall nethogs dnsutils coreutils lsof
    # carla rnnoise-plugin
    # libjack2 jack2
  ];

  environment.pathsToLink = [ "/share/zsh" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.useDns = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
