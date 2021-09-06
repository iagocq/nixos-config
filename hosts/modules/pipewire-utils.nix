{ lib }:

rec {
  virtual-sinks = sinks:
    map (sink:
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "pa_vsink_" + (lib.strings.toLower (builtins.replaceStrings [ " " ]  [ "_" ] sink));
          "node.description" = sink + " (Sink)";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
    ) sinks;
  virtual-sources = sources:
    map (source:
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "pa_vsource_" + (lib.strings.toLower (builtins.replaceStrings [ " " ]  [ "_" ] source));
          "node.description" = source + " (Source)";
          "media.class" = "Audio/Source/Virtual";
          "audio.position" = "FL,FR";
        };
      }
    ) sources;
}
