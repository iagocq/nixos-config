{ config, pkgs, lib, ... }:

{
  home.file.".asoundrc".text = ''
        pcm.loophw00 {
          type hw
          card 10
          device 0
          subdevice 0
        }
        pcm.amix {
          type dmix
          ipc_key 219345
          slave {
            pcm loophw00

          }
        }
        pcm.asoftvol {
          type softvol
          slave.pcm "amix"
          control { name PCM }
        }
        pcm.cloop {
          type hw
          card 10
          device 1
          subdevice 0
          format S32_LE
        }
        pcm.loophw01 {
          type hw
          card 10
          device 0
          subdevice 1
        }
        pcm.ploop {
          type hw
          card 10
          device 1
          subdevice 1
          format S32_LE
        }
        pcm.aduplex {
          type asym
          playback.pcm "asoftvol"
          capture.pcm "loophw01"
        }
        pcm.!default {
          type plug
          slave.pcm aduplex
          hint {
            show on
            description "Duplex Loopback"
          }
        }
  '';
  xdg.configFile."pulse/daemon.conf.d/realtime.conf".text = ''
    realtime-scheduling=no
    realtime-priority=50
  '';
  xdg.configFile."pipewire/pipewire.conf".text = ''
    context.properties = {
      default.clock.quantum = 1024
      default.clock.min-quantum = 1024
      default.clock.max-quantum = 4096
    }
  '';
} 
