{ config, lib, pkgs, ... }:

{
  device = {
    type = "desktop";

    zfs = {
      base = "rpool/crypt";
      hostId = "7afc33d0";
    };

    network = {
      interfaces.dhcp = [ "enp8s0" ];
      firewall = false;
    };

    audio = {
      playback = "alsa_output.pci-0000_09_00.1.hdmi-stereo";
      capture = "alsa_input.usb-Generalplus_Usb_Audio_Device_13662631792-00.mono-fallback";
      loopbacks = true;
      noiseSuppression = true;
      quantum = 256;
    };

    graphics = {
      autoLogin.user = "iago";
      de = "xfce";
      wm = "i3";
      xconfig = {
        layout = "br";
        videoDrivers = [ "nvidia" ];
        dpi = 96;
        screenSection = ''
          Option "metamodes" "nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }"
          Option "TripleBuffer" "on"
          Option "AllowIndirectGLXProtocol" "off"
        '';
      };
    };
  };
}
