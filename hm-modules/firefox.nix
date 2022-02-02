{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.custom.firefox;
in
{
  options.custom.firefox = {
    enable = mkEnableOption "";

    profile = mkOption {
      type = types.attrsOf types.anything;
      default = {
        isDefault = true;
        userChrome = builtins.readFile ./firefox/userChrome.css;
        settings = cfg.settings;
      };
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {
        "browser.aboutConfig.showWarning" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.startupPage" = 3;
        "browser.slowStartup.notificationDisabled" = true;
        "browser.download.useDownloadDir" = false;
        "browser.theme.content-theme" = 0;
        "browser.theme.toolbar-theme" = 0;
        "browser.urlbar.suggest.searches" = false;
        "general.autoScroll" = true;
        "sidebar.position_start" = false;
      };
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.${config.home.username} = cfg.profile;
      extensions = cfg.extensions;
    };
  };
}
