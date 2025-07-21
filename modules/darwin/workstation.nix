{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.darwin;
in
{
  meta.maintainers = [ maintainers.quartz55 ];

  options.darwin = {
    enable = mkEnableOption ''
      Enable Darwin workstation module
    '';

    capsLockIsControl = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    system.defaults = {
      dock = {
        autohide = true;
        mru-spaces = false;
        minimize-to-application = false;
        orientation = "left";
      };

      finder = {
        QuitMenuItem = true;
        AppleShowAllExtensions = true;
        _FXShowPosixPathInTitle = true;
        FXEnableExtensionChangeWarning = false;
      };

      trackpad = {
        Clicking = false;
        TrackpadThreeFingerDrag = true;
      };
    };

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = cfg.capsLockIsControl;
    };
  };
}
