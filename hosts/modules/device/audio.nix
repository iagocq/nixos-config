{ config, lib, pkgs, ... }@args:

with lib;
let
  cfg = config.device.audio;
  pw = import ./pipewire args;
in
{
  options.device.audio = {
    enable = mkOption {
      type = types.bool;
      default = with config.device; hasAudio && !isHomeManager;
    };

    backend = mkOption {
      type = types.enum [ "pipewire" "pulseaudio" ];
      default = "pipewire";
    };

    loopbacks = mkOption {
      type = types.bool;
      default = false;
    };

    loopbacksModules = mkOption {
      type = types.listOf types.attrs;
      default = pw.virtualSinks [
        { name = "Call"; target = cfg.playback; }
        { name = "Desktop"; target = cfg.playback; }
      ] ++ pw.virtualSources [
        { name = "Mixed"; }
      ];
    };

    noiseSuppression = mkOption {
      type = types.bool;
      default = false;
    };

    noiseSuppressionModule = mkOption {
      type = types.attrs;
      default = pw.filterGraphModule {
        name = pw.sourcify "Voice";
        description = "Voice (Source)";
        nodes = [
          {
            type = "ladspa";
            name = "rnnoise";
            plugin = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
            label = "noise_suppressor_stereo";
            control = {
              "VAD Threshold (%)" = "0.0";
            };
          }
        ];
        capture = {
          "node.passive" = true;
          "node.target" = cfg.capture;
        };
        playback = {
          "media.class" = "Audio/Source";
          "node.target" = "_invalid_";
          "audio.position" = [ "FL" "FR" ];
        };
      };
    };

    playback = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    capture = mkOption {
      type = types.nullOr types.str;
      default = null;
    };

    realtime = mkOption {
      type = types.bool;
      default = config.device.isDesktop;
    };

    quantum = mkOption {
      type = types.ints.positive;
      default = if config.device.isDesktop then 1024 else 2048;
    };

    modules = mkOption {
      type = types.listOf types.attrs;
      default = [
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-profiler"; }
        { name = "libpipewire-module-metadata"; }
        { name = "libpipewire-module-spa-device-factory"; }
        { name = "libpipewire-module-spa-node-factory"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-client-device"; }
        { name = "libpipewire-module-portal"; flags = [ "ifexists" "nofail" ]; }
        { name = "libpipewire-module-access"; args = {}; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
      ] ++ optionals cfg.realtime [
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
      ] ++ optionals cfg.loopbacks cfg.loopbacksModules
        ++ optionals cfg.noiseSuppression [ cfg.noiseSuppressionModule ];
    };

    pwPulseModules = mkOption {
      type = types.listOf types.attrs;
      default = [
        { name = "libpipewire-module-protocol-native"; }
        { name = "libpipewire-module-client-node"; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-metadata"; }
        {
          name = "libpipewire-module-protocol-pulse";
          args = let quantumstr = toString cfg.quantum; in {
            "pulse.min.req" = "${quantumstr}/48000";
            "pulse.default.req" = "${quantumstr}/48000";
            "pulse.max.req" = "${quantumstr}/48000";
            "pulse.min.quantum" = "${quantumstr}/48000";
            "pulse.max.quantum" = "${quantumstr}/48000";
            "server.address" = [ "unix:native" ];
          };
        }
      ] ++ optionals cfg.realtime [
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
      ];
    };
  };

  config = mkIf cfg.enable {
    services.pipewire = mkIf (cfg.backend == "pipewire") {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = cfg.loopbacks;

      config.pipewire = {
        "context.properties" = {
          "default.clock.quantum" = cfg.quantum;
          "default.clock.min-quantum" = cfg.quantum;
          "default.clock.max-quantum" = cfg.quantum;
          "log.level" = 2;
          "link.max-buffers" = 64;
        };

        "context.objects" = [
          {
            factory = "spa-node-factory";
            args = {
              "factory.name" = "support.node.driver";
              "node.name" = "Dummy-Driver";
              "node.group" = "pipewire.dummy";
              "priority.driver" = 8000;
            };
          }
        ];

        "context.modules" = cfg.modules;
      };

      config.pipewire-pulse = {
        "context.properties" = {
          "log.level" = 2;
        };

        "context.modules" = cfg.pwPulseModules;
      };

      media-session.config.alsa-monitor.rules = [
        {
          "actions"."update-props" = {
            "api.acp.auto-port" = false;
            "api.acp.auto-profile" = false;
            "api.alsa.use-acp" = true;
          };
          "matches" = [ { "device-name" = "~alsa_card.*"; } ];
        }
        {
          "actions"."update-props" = {
            "node.pause-on-idle" = false;
            "api.alsa.headroom" = 1024;
          };
          "matches" = [ { "node.name" = "~alsa_input.*"; } { "node.name" = "~alsa_output.*"; } ];
        }
      ];
    };

    security.rtkit.enable = mkDefault cfg.realtime;
  };
}
