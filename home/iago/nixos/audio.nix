{ config, lib, pkgs, ... }:

let
  quantum = 256;
  quantumstr = builtins.toString quantum;
  pw-utils = import ./pipewire-utils.nix { lib = lib; };
  pw-pa-virtual-sinks = pw-utils.virtual-sinks;
  pw-pa-virtual-sources = pw-utils.virtual-sources;
in
{
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
            "priority.driver" = 8000;
          };
        }
      ] ++ (pw-pa-virtual-sinks   [ "Call" "Desktop" "Extra" ])
        ++ (pw-pa-virtual-sources [ "Voice" "Mixed"  "Extra" ]);
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
}
