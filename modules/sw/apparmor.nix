{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.sw.apparmor;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  # TODO: research
  options.lonsdaleite.sw.apparmor = (mkEnableFrom [ "sw" ] "Enables apparmor")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    security.apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      #TODO: implement? write my own? 
      # includes = { };
      # policies = { };
    };
  };
}
