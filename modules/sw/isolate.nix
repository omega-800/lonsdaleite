{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.sw.isolate;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  # TODO: research
  options.lonsdaleite.sw.isolate = (mkEnableFrom [ "sw" ] "Enables isolate")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    #TODO: figure out what the hell this is
    security.isolate = { enable = true; };
  };
}
