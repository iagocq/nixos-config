{ lib, ... }:

with lib;
rec {
  namify = name: strings.toLower (builtins.replaceStrings [ " " ] [ "_" ] name);
  sinkify = name: "pw_vsink_" + namify name;
  sourcify = name: "pw_vsource_" + namify name;

  loopbackModule = { name, description, capture ? null, playback ? null }: {
    name = "libpipewire-module-loopback";
    args = {
      "node.name" = name;
      "node.description" = description;
    } // optionalAttrs (capture != null) { "capture.props" = capture; }
      // optionalAttrs (playback != null) { "playback.props" = playback; };
  };

  filterGraphModule = { name, description, nodes ? [], capture ? null, playback ? null }: {
    name = "libpipewire-module-filter-chain";
    args = {
      "node.name" = name;
      "node.description" = description;
      "filter.graph" = {
        "nodes" = nodes;
      };
    } // optionalAttrs (capture != null) { "capture.props" = capture; }
      // optionalAttrs (playback != null) { "playback.props" = playback; };
  };

  virtualSink = {
    name
  , target ? "_invalid_"
  , capture ? { "audio.position" = [ "FL" "FR" ]; }
  , playback ? { "audio.position" = [ "FL" "FR" ]; } }:
  loopbackModule {
    name = sinkify name;
    description = name + " (Sink)";
    capture = {
      "media.class" = "Audio/Sink";
      "node.target" = "_invalid_";
    } // capture;
    playback = {
      "node.passive" = true;
      "node.target" = target;
    } // playback;
  };

  virtualSource = {
    name
  , target ? "_invalid_"
  , capture ? { "audio.position" = [ "FL" "FR" ]; }
  , playback ? { "audio.position" = [ "FL" "FR" ]; } }:
  loopbackModule {
    name = sourcify name;
    description = name + " (Source)";
    capture = {
      "node.target" = target;
      "node.passive" = true;
    } // capture;
    playback = {
      "media.class" = "Audio/Source";
      "node.target" = "_invalid_";
    } // playback;
  };

  virtualSinks = sinks: map (sink: virtualSink sink) sinks;
  virtualSources = sources: map (source: virtualSource source) sources;
}
