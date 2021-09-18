{ lib }:

with lib;

let
in
rec {
  namify = name: strings.toLower (builtins.replaceStrings [" "] ["_"] name);
  sinkify = name: "pw_vsink_" + namify name;
  sourcify = name: "pw_vsource_" + namify name;
  
  loopback-module = {
    name, description,
    capture ? null, playback ? null}:
  {
    name = "libpipewire-module-loopback";
    args = {
      "node.name" = name;
      "node.description" = description;
    } // optionalAttrs (capture != null) { "capture.props" = capture; }
      // optionalAttrs (playback != null) { "playback.props" = playback; };
  };
  
  virtual-sink = {
    name, target ? null,
    capture ? { "audio.position" = [ "FL" "FR" ]; },
    playback ? { "audio.position" = [ "FL" "FR" ]; } }:
  loopback-module {
    name = sinkify name;
    description = name + " (Sink)";
    capture = {
      "media.class" = "Audio/Sink";
      "node.target" = "_invalid_";
    };
    playback = {
      "node.target" = target;
      "node.passive" = true;
    } // optionalAttrs (target != null) { node.target = target; };
  };

  virtual-source = {
    name, target ? null,
    capture ? { "audio.position" = [ "FL" "FR" ]; },
    playback ? { "audio.position" = [ "FL" "FR" ]; } }:
  loopback-module {
    name = sourcify name;
    description = name + " (Source)";
    capture = {
      "node.target" = target;
      "node.passive" = true;
    } // optionalAttrs (target != null) { node.target = target; }
      // capture;
    playback = {
      "media.class" = "Audio/Source";
      "node.target" = "_invalid_";
    } // playback;
  };

  filter-graph-module = {
    name, description,
    nodes ? [], capture ? null, playback ? null }:
  {
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

  virtual-sinks = sinks: map (sink: virtual-sink sink) sinks;
  virtual-sources = sources: map (source: virtual-source source) sources;
}
