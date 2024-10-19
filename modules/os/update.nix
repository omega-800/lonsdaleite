{ config, lib, lon-lib, ... }:
let
  cfg = config.lonsdaleite.os.update;
  inherit (lib) mkIf;
  inherit (lon-lib) mkEnableFrom;
in
{
  options.lonsdaleite.os.update =
    (mkEnableFrom [ "os" ] "Enables automatic updates");
  config = mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      # TODO: make this configurable
      allowReboot = false;
      dates = "04:00";
      flags = [ "--update-input" "lonsdaleite" ];
      # TODO: flake = "";
      operation = "switch";
      randomizedDelaySec = "15min";
      rebootWindow = {
        lower = "01:00";
        upper = "05:00";
      };
    };
  };
}
