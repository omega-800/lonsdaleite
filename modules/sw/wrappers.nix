{ config, lib, lonLib, ... }:
let
  cfg = config.lonsdaleite.sw.wrappers;
  inherit (lib) mkIf;
  inherit (lonLib) mkEnableFrom mkParanoiaFrom;
in {
  # TODO: research
  options.lonsdaleite.sw.wrappers = (mkEnableFrom [ "sw" ] "Enables wrappers")
    // (mkParanoiaFrom [ "sw" ] [ "" "" "" ]) // { };

  config = mkIf cfg.enable {
    #TODO: figure out what the hell this is
    security.wrappers = { };
  };
}