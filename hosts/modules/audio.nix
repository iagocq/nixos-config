{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.common.audio;
  quantum = cfg.quantum;
  quantumstr = builtins.toString quantum;
  pw-utils = import ./pipewire-utils.nix { inherit lib; };
  virtual-sinks = pw-utils.virtual-sinks;
  virtual-sources = pw-utils.virtual-sources;
  sinkify = pw-utils.sinkify;
  sourcify = pw-utils.sourcify;
  filter-graph-module = pw-utils.filter-graph-module;
in
{
  options.common.audio = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };

    quantum = mkOption {
      type = types.ints.positive;
      default = 1024;
    };

    default-playback = mkOption {
      type = types.str;
      default = "";
    };

    default-capture = mkOption {
      type = types.str;
      default = "";
    };

    default-modules = mkOption {
      type = types.anything;
      default = [
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
        { name = "libpipewire-module-portal"; flags = [ "ifexists" "nofail" ]; }
        { name = "libpipewire-module-access"; args = {}; }
        { name = "libpipewire-module-adapter"; }
        { name = "libpipewire-module-link-factory"; }
        { name = "libpipewire-module-session-manager"; }
      ];
    };
  };

  config = mkIf cfg.enable {
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
        "context.modules" = (cfg.default-modules
        ) ++ virtual-sinks [
          { name = "Call"; target = cfg.default-playback; }
          { name = "Desktop"; target = cfg.default-playback; }
        ] ++ virtual-sources [
          { name = "Mixed"; }
        ] ++ [ (filter-graph-module {
          name = sourcify "Voice";
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
            "node.target" = cfg.default-capture;
          };
          playback = {
            "media.class" = "Audio/Source";
            "node.target" = "_invalid_";
            "audio.position" = [ "FL" "FR" ];
          };
        }) ];
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

    security.rtkit.enable = true;
  };
}
